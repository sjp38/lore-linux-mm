Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C3F8D6B0038
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 04:59:43 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so72088968pab.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 01:59:43 -0700 (PDT)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.187])
        by mx.google.com with ESMTPS id qo8si10308565pac.117.2015.09.28.01.59.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 01:59:43 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
Date: Mon, 28 Sep 2015 08:58:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBA3BF7@AcuExch.aculab.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
 <2524822.pQu4UKMrlb@vostro.rjw.lan>
 <1443297128.2181.11.camel@HansenPartnership.com>
 <3461169.v5xKdGLGjP@vostro.rjw.lan>
In-Reply-To: <3461169.v5xKdGLGjP@vostro.rjw.lan>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Rafael J. Wysocki'" <rjw@rjwysocki.net>, James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Johannes Berg <johannes@sipsolutions.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, QCA ath9k
 Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO
 POWER MANAGEM..." <alsa-devel@alsa-project.org>

RnJvbTogUmFmYWVsIEouIFd5c29ja2kNCj4gU2VudDogMjcgU2VwdGVtYmVyIDIwMTUgMTU6MDkN
Ci4uLg0KPiA+ID4gU2F5IHlvdSBoYXZlIHRocmVlIGFkamFjZW50IGZpZWxkcyBpbiBhIHN0cnVj
dHVyZSwgeCwgeSwgeiwgZWFjaCBvbmUgYnl0ZSBsb25nLg0KPiA+ID4gSW5pdGlhbGx5LCBhbGwg
b2YgdGhlbSBhcmUgZXF1YWwgdG8gMC4NCj4gPiA+DQo+ID4gPiBDUFUgQSB3cml0ZXMgMSB0byB4
IGFuZCBDUFUgQiB3cml0ZXMgMiB0byB5IGF0IHRoZSBzYW1lIHRpbWUuDQo+ID4gPg0KPiA+ID4g
V2hhdCdzIHRoZSByZXN1bHQ/DQo+ID4NCj4gPiBJIHRoaW5rIGV2ZXJ5IENQVSdzICBjYWNoZSBh
cmNoaXRlY3VyZSBndWFyYW50ZWVzIGFkamFjZW50IHN0b3JlDQo+ID4gaW50ZWdyaXR5LCBldmVu
IGluIHRoZSBmYWNlIG9mIFNNUCwgc28gaXQncyB4PT0xIGFuZCB5PT0yLiAgSWYgeW91J3JlDQo+
ID4gdGhpbmtpbmcgb2Ygb2xkIGFscGhhIFNNUCBzeXN0ZW0gd2hlcmUgdGhlIGxvd2VzdCBzdG9y
ZSB3aWR0aCBpcyAzMiBiaXRzDQo+ID4gYW5kIHRodXMgeW91IGhhdmUgdG8gZG8gUk1XIHRvIHVw
ZGF0ZSBhIGJ5dGUsIHRoaXMgd2FzIHVzdWFsbHkgZml4ZWQgYnkNCj4gPiBwYWRkaW5nIChhc3N1
bWluZyB0aGUgc3RydWN0dXJlIGlzIG5vdCBwYWNrZWQpLiAgSG93ZXZlciwgaXQgd2FzIHN1Y2gg
YQ0KPiA+IHByb2JsZW0gdGhhdCBldmVuIHRoZSBsYXRlciBhbHBoYSBjaGlwcyBoYWQgYnl0ZSBl
eHRlbnNpb25zLg0KDQpEb2VzIGxpbnV4IHN0aWxsIHN1cHBvcnQgdGhvc2Ugb2xkIEFscGhhcz8N
Cg0KVGhlIHg4NiBjcHVzIHdpbGwgYWxzbyBkbyAzMmJpdCB3aWRlIHJtdyBjeWNsZXMgZm9yIHRo
ZSAnYml0JyBvcGVyYXRpb25zLg0KDQo+IE9LLCB0aGFua3MhDQoNCllvdSBzdGlsbCBoYXZlIHRv
IGVuc3VyZSB0aGUgY29tcGlsZXIgZG9lc24ndCBkbyB3aWRlciBybXcgY3ljbGVzLg0KSSBiZWxp
ZXZlIHRoZSByZWNlbnQgdmVyc2lvbnMgb2YgZ2NjIHdvbid0IGRvIHdpZGVyIGFjY2Vzc2VzIGZv
ciB2b2xhdGlsZSBkYXRhLg0KDQoJRGF2aWQNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
