#include "console_panel.h"
#include "state.h"
#include "spdlog/spdlog.h"

#include <algorithm>
#include <cctype>

LV_IMG_DECLARE(delete_img);
LV_FONT_DECLARE(dejavusans_mono_14);

ConsolePanel::ConsolePanel(KWebSocketClient &websocket_client, std::mutex &lock, lv_obj_t *parent)
  : ws(websocket_client)
  , lv_lock(lock)
  , console_cont(lv_obj_create(parent))
  , top_cont(lv_obj_create(console_cont))
  , output(lv_textarea_create(top_cont))
  , delete_btn(top_cont, &delete_img, "Delete", &ConsolePanel::_handle_delete_btn, this)
{
  lv_obj_align(console_cont, LV_ALIGN_CENTER, 0, 0);
  lv_obj_set_size(console_cont, LV_PCT(100), LV_PCT(100));
  lv_obj_set_flex_flow(console_cont, LV_FLEX_FLOW_COLUMN);
  lv_obj_set_style_pad_all(console_cont, 0, 0);
  lv_obj_set_style_text_font(console_cont, &dejavusans_mono_14, LV_STATE_DEFAULT);

  lv_obj_set_flex_grow(top_cont, 1);
  lv_obj_set_style_pad_all(top_cont, 0, 0);
  lv_obj_set_width(top_cont, LV_PCT(100));

  lv_obj_set_style_border_width(output, 0, 0);
  lv_obj_set_size(output, LV_PCT(100), LV_PCT(100));
  lv_obj_set_style_border_width(output, 0, LV_STATE_FOCUSED | LV_PART_CURSOR);
  lv_obj_align(delete_btn.get_container(), LV_ALIGN_BOTTOM_RIGHT, 0, -20);

  ws.register_method_callback("notify_gcode_response",
			      "ConsolePanel",
			      [this](json& d) { this->handle_macro_response(d); });
}

ConsolePanel::~ConsolePanel() {
  if (console_cont != NULL) {
    lv_obj_del(console_cont);
    console_cont = NULL;
  }
}

lv_obj_t *ConsolePanel::get_container() {
  return console_cont;
}

void ConsolePanel::handle_macro_response(json &j) {
  spdlog::trace("console macro response {}", j.dump());

  if (j.contains("params")) {
    std::lock_guard<std::mutex> lock(lv_lock);
    for (auto &l : j["params"]) {
      lv_textarea_add_text(output, l.template get<std::string>().c_str());
      lv_textarea_add_text(output, "\n");
    }
  }
}

void ConsolePanel::handle_delete_btn(lv_event_t *e) {
  lv_textarea_set_text(output, "");
}
