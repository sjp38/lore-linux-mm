Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id C6DE26B0038
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 10:52:12 -0400 (EDT)
Received: by oiww128 with SMTP id w128so91410060oiw.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 07:52:12 -0700 (PDT)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.192])
        by mx.google.com with ESMTPS id v62si8369399oib.14.2015.09.28.07.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 07:52:12 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
Date: Mon, 28 Sep 2015 14:50:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBA4232@AcuExch.aculab.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	 <2524822.pQu4UKMrlb@vostro.rjw.lan>
	 <1443297128.2181.11.camel@HansenPartnership.com>
	 <3461169.v5xKdGLGjP@vostro.rjw.lan>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBA3BF7@AcuExch.aculab.com>
 <1443450406.2168.3.camel@HansenPartnership.com>
In-Reply-To: <1443450406.2168.3.camel@HansenPartnership.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'James Bottomley' <James.Bottomley@HansenPartnership.com>
Cc: "'Rafael J. Wysocki'" <rjw@rjwysocki.net>, Viresh Kumar <viresh.kumar@linaro.org>, Johannes Berg <johannes@sipsolutions.net>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO
 POWER MANAGEM..." <alsa-devel@alsa-project.org>

RnJvbTogSmFtZXMgQm90dG9tbGV5IFttYWlsdG86SmFtZXMuQm90dG9tbGV5QEhhbnNlblBhcnRu
ZXJzaGlwLmNvbV0NCj4gU2VudDogMjggU2VwdGVtYmVyIDIwMTUgMTU6MjcNCj4gT24gTW9uLCAy
MDE1LTA5LTI4IGF0IDA4OjU4ICswMDAwLCBEYXZpZCBMYWlnaHQgd3JvdGU6DQo+ID4gRnJvbTog
UmFmYWVsIEouIFd5c29ja2kNCj4gPiA+IFNlbnQ6IDI3IFNlcHRlbWJlciAyMDE1IDE1OjA5DQo+
ID4gLi4uDQo+ID4gPiA+ID4gU2F5IHlvdSBoYXZlIHRocmVlIGFkamFjZW50IGZpZWxkcyBpbiBh
IHN0cnVjdHVyZSwgeCwgeSwgeiwgZWFjaCBvbmUgYnl0ZSBsb25nLg0KPiA+ID4gPiA+IEluaXRp
YWxseSwgYWxsIG9mIHRoZW0gYXJlIGVxdWFsIHRvIDAuDQo+ID4gPiA+ID4NCj4gPiA+ID4gPiBD
UFUgQSB3cml0ZXMgMSB0byB4IGFuZCBDUFUgQiB3cml0ZXMgMiB0byB5IGF0IHRoZSBzYW1lIHRp
bWUuDQo+ID4gPiA+ID4NCj4gPiA+ID4gPiBXaGF0J3MgdGhlIHJlc3VsdD8NCj4gPiA+ID4NCj4g
PiA+ID4gSSB0aGluayBldmVyeSBDUFUncyAgY2FjaGUgYXJjaGl0ZWN1cmUgZ3VhcmFudGVlcyBh
ZGphY2VudCBzdG9yZQ0KPiA+ID4gPiBpbnRlZ3JpdHksIGV2ZW4gaW4gdGhlIGZhY2Ugb2YgU01Q
LCBzbyBpdCdzIHg9PTEgYW5kIHk9PTIuICBJZiB5b3UncmUNCj4gPiA+ID4gdGhpbmtpbmcgb2Yg
b2xkIGFscGhhIFNNUCBzeXN0ZW0gd2hlcmUgdGhlIGxvd2VzdCBzdG9yZSB3aWR0aCBpcyAzMiBi
aXRzDQo+ID4gPiA+IGFuZCB0aHVzIHlvdSBoYXZlIHRvIGRvIFJNVyB0byB1cGRhdGUgYSBieXRl
LCB0aGlzIHdhcyB1c3VhbGx5IGZpeGVkIGJ5DQo+ID4gPiA+IHBhZGRpbmcgKGFzc3VtaW5nIHRo
ZSBzdHJ1Y3R1cmUgaXMgbm90IHBhY2tlZCkuICBIb3dldmVyLCBpdCB3YXMgc3VjaCBhDQo+ID4g
PiA+IHByb2JsZW0gdGhhdCBldmVuIHRoZSBsYXRlciBhbHBoYSBjaGlwcyBoYWQgYnl0ZSBleHRl
bnNpb25zLg0KPiA+DQo+ID4gRG9lcyBsaW51eCBzdGlsbCBzdXBwb3J0IHRob3NlIG9sZCBBbHBo
YXM/DQo+ID4NCj4gPiBUaGUgeDg2IGNwdXMgd2lsbCBhbHNvIGRvIDMyYml0IHdpZGUgcm13IGN5
Y2xlcyBmb3IgdGhlICdiaXQnIG9wZXJhdGlvbnMuDQo+IA0KPiBUaGF0J3MgZGlmZmVyZW50OiBp
dCdzIGFuIGF0b21pYyBSTVcgb3BlcmF0aW9uLiAgVGhlIHByb2JsZW0gd2l0aCB0aGUNCj4gYWxw
aGEgd2FzIHRoYXQgdGhlIG9wZXJhdGlvbiB3YXNuJ3QgYXRvbWljIChtZWFuaW5nIHRoYXQgaXQg
Y2FuJ3QgYmUNCj4gaW50ZXJydXB0ZWQgYW5kIG5vIGludGVybWVkaWF0ZSBvdXRwdXQgc3RhdGVz
IGFyZSB2aXNpYmxlKS4NCg0KSXQgaXMgb25seSBhdG9taWMgaWYgcHJlZml4ZWQgYnkgdGhlICds
b2NrJyBwcmVmaXguDQpOb3JtYWxseSB0aGUgcmVhZCBhbmQgd3JpdGUgYXJlIHNlcGFyYXRlIGJ1
cyBjeWNsZXMuDQogDQo+ID4gWW91IHN0aWxsIGhhdmUgdG8gZW5zdXJlIHRoZSBjb21waWxlciBk
b2Vzbid0IGRvIHdpZGVyIHJtdyBjeWNsZXMuDQo+ID4gSSBiZWxpZXZlIHRoZSByZWNlbnQgdmVy
c2lvbnMgb2YgZ2NjIHdvbid0IGRvIHdpZGVyIGFjY2Vzc2VzIGZvciB2b2xhdGlsZSBkYXRhLg0K
PiANCj4gSSBkb24ndCB1bmRlcnN0YW5kIHRoaXMgY29tbWVudC4gIFlvdSBzZWVtIHRvIGJlIGlt
cGx5aW5nIGdjYyB3b3VsZCBkbyBhDQo+IDY0IGJpdCBSTVcgZm9yIGEgMzIgYml0IHN0b3JlIC4u
LiB0aGF0IHdvdWxkIGJlIGRhZnQgd2hlbiBhIHNpbmdsZQ0KPiBpbnN0cnVjdGlvbiBleGlzdHMg
dG8gcGVyZm9ybSB0aGUgb3BlcmF0aW9uIG9uIGFsbCBhcmNoaXRlY3R1cmVzLg0KDQpSZWFkIHRo
ZSBvYmplY3QgY29kZSBhbmQgd2VlcC4uLg0KSXQgaXMgbW9zdCBsaWtlbHkgdG8gaGFwcGVuIGZv
ciBvcGVyYXRpb25zIHRoYXQgYXJlIHJtdyAoZWcgYml0IHNldCkuDQpGb3IgaW5zdGFuY2UgdGhl
IGFybSBjcHUgaGFzIGxpbWl0ZWQgb2Zmc2V0cyBmb3IgMTZiaXQgYWNjZXNzZXMsIGZvcg0Kbm9y
bWFsIHN0cnVjdHVyZXMgdGhlIGNvbXBpbGVyIGlzIGxpa2VseSB0byB1c2UgYSAzMmJpdCBybXcg
c2VxdWVuY2UNCmZvciBhIDE2Yml0IGZpZWxkIHRoYXQgaGFzIGEgbGFyZ2Ugb2Zmc2V0Lg0KVGhl
IEMgbGFuZ3VhZ2UgYWxsb3dzIHRoZSBjb21waWxlciB0byBkbyBpdCBmb3IgYW55IGFjY2VzcyAo
SUlSQyBpbmNsdWRpbmcNCnZvbGF0aWxlcykuDQoNCglEYXZpZA0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
