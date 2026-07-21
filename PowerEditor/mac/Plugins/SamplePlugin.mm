// Sample macOS plugin for Notepad++ (demonstrates PluginHost ABI)
#import <Foundation/Foundation.h>

typedef struct NppMacPluginInfo {
	const char *name;
	const char *version;
	const char *author;
} NppMacPluginInfo;

static const NppMacPluginInfo kInfo = {
	"Sample Plugin",
	"1.0.0",
	"Notepad++ macOS port"
};

extern "C" {

__attribute__((visibility("default"))) const NppMacPluginInfo *NppMac_GetInfo(void)
{
	return &kInfo;
}

__attribute__((visibility("default"))) void NppMac_Init(void)
{
	NSLog(@"[SamplePlugin] initialized");
}

__attribute__((visibility("default"))) void NppMac_Cleanup(void)
{
	NSLog(@"[SamplePlugin] cleaned up");
}

}
