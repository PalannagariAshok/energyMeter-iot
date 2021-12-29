//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <iot_demo/iot_demo_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) iot_demo_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "IotDemoPlugin");
  iot_demo_plugin_register_with_registrar(iot_demo_registrar);
}
