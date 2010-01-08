Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 870A36B0092
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 00:18:09 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Fri, 8 Jan 2010 13:18:01 +0800
Subject: RE: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel(v1)
Message-ID: <DA586906BA1FFC4384FCFD6429ECE86031560C27@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
 <4B46BC6F.5060607@kernel.org>
In-Reply-To: <4B46BC6F.5060607@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

VGhhbmtzIFBldGVyLCBteSB0ZXN0aW5nIHNob3dzIHRoYXQgdGhlcmUgYXJlIG1hbnkgaXNzdWVz
IG9uIDMyLWJpdCBrZXJuZWwgZm9yIG1lbW9yeSBob3QtYWRkLCB0aGVyZSBhcmUgc3RpbGwgbW9y
ZSB3b3JrcyB0byBkbyBmb3IgMzItYml0IGtlcm5lbHMobW9yZSB0aGFuIDIgcGF0Y2hlcykuIE1l
bW9yeSBob3QtYWRkIGlzIG11Y2ggbW9yZSBpbXBvcnRhbnQgb24gNjQtYml0IGtlcm5lbCwgSSB0
aGluayB0aGF0IHdlIGNhbiBmaXggdGhlIGJ1ZyBvbiA2NC1iaXQga2VybmVsIGZpcnN0LiAzMi1r
ZXJuZWwgaG90cGx1ZyBpcyB0aGUgd29ya2luZyBpbiBuZXh0IHN0ZXAuDQoNClRoYW5rcyAmIFJl
Z2FyZHMsDQpTaGFvaHVpDQoNCg0KLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IEgu
IFBldGVyIEFudmluIFttYWlsdG86aHBhQGtlcm5lbC5vcmddIA0KU2VudDogRnJpZGF5LCBKYW51
YXJ5IDA4LCAyMDEwIDE6MDMgUE0NClRvOiBaaGVuZywgU2hhb2h1aQ0KQ2M6IGxpbnV4LW1tQGt2
YWNrLm9yZzsgYWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZzsgbGludXgta2VybmVsQHZnZXIua2Vy
bmVsLm9yZzsgYWtAbGludXguaW50ZWwuY29tOyB5LWdvdG9AanAuZnVqaXRzdS5jb207IERhdmUg
SGFuc2VuOyBXdSwgRmVuZ2d1YW5nOyB4ODZAa2VybmVsLm9yZw0KU3ViamVjdDogUmU6IFtQQVRD
SCAtIHJlc2VuZF0gTWVtb3J5LUhvdHBsdWc6IEZpeCB0aGUgYnVnIG9uIGludGVyZmFjZSAvZGV2
L21lbSBmb3IgNjQtYml0IGtlcm5lbCh2MSkNCg0KT24gMDEvMDcvMjAxMCAwNzozMiBQTSwgWmhl
bmcsIFNoYW9odWkgd3JvdGU6DQo+IFJlc2VuZCB0aGUgcGF0Y2ggdG8gdGhlIG1haWxpbmctbGlz
dCwgdGhlIG9yaWdpbmFsIHBhdGNoIFVSTCBpcyANCj4gaHR0cDovL3BhdGNod29yay5rZXJuZWwu
b3JnL3BhdGNoLzY5MDc1LywgaXQgaXMgbm90IGFjY2VwdGVkIHdpdGhvdXQgY29tbWVudHMsDQo+
IHNlbnQgaXQgYWdhaW4gdG8gcmV2aWV3Lg0KPiANCj4gTWVtb3J5LUhvdHBsdWc6IEZpeCB0aGUg
YnVnIG9uIGludGVyZmFjZSAvZGV2L21lbSBmb3IgNjQtYml0IGtlcm5lbA0KPiANCj4gVGhlIG5l
dyBhZGRlZCBtZW1vcnkgY2FuIG5vdCBiZSBhY2Nlc3MgYnkgaW50ZXJmYWNlIC9kZXYvbWVtLCBi
ZWNhdXNlIHdlIGRvIG5vdA0KPiAgdXBkYXRlIHRoZSB2YXJpYWJsZSBoaWdoX21lbW9yeS4gVGhp
cyBwYXRjaCBhZGQgYSBuZXcgZTgyMCBlbnRyeSBpbiBlODIwIHRhYmxlLA0KPiAgYW5kIHVwZGF0
ZSBtYXhfcGZuLCBtYXhfbG93X3BmbiBhbmQgaGlnaF9tZW1vcnkuDQo+IA0KPiBXZSBhZGQgYSBm
dW5jdGlvbiB1cGRhdGVfcGZuIGluIGZpbGUgYXJjaC94ODYvbW0vaW5pdC5jIHRvIHVkcGF0ZSB0
aGVzZQ0KPiAgdmFyaWJsZXMuIE1lbW9yeSBob3RwbHVnIGRvZXMgbm90IG1ha2Ugc2Vuc2Ugb24g
MzItYml0IGtlcm5lbCwgc28gd2UgZGlkIG5vdA0KPiAgY29uY2VybiBpdCBpbiB0aGlzIGZ1bmN0
aW9uLg0KPiANCg0KTWVtb3J5IGhvdHBsdWcgbWFrZXMgc2Vuc2Ugb24gMzItYml0IGtlcm5lbHMs
IGF0IGxlYXN0IGluIHZpcnR1YWwNCmVudmlyb25tZW50cy4NCg0KCS1ocGENCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
