Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 768E26B025B
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 11:32:42 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so80586925pab.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 08:32:42 -0700 (PDT)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.194])
        by mx.google.com with ESMTPS id iw10si29304388pbc.140.2015.09.28.08.32.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 08:32:41 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
Date: Mon, 28 Sep 2015 15:31:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBA42F5@AcuExch.aculab.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	 <2524822.pQu4UKMrlb@vostro.rjw.lan>
	 <1443297128.2181.11.camel@HansenPartnership.com>
	 <3461169.v5xKdGLGjP@vostro.rjw.lan>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBA3BF7@AcuExch.aculab.com>
	 <1443450406.2168.3.camel@HansenPartnership.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBA4232@AcuExch.aculab.com>
 <1443453111.2168.9.camel@HansenPartnership.com>
In-Reply-To: <1443453111.2168.9.camel@HansenPartnership.com>
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

RnJvbTogSmFtZXMgQm90dG9tbGV5IA0KPiBTZW50OiAyOCBTZXB0ZW1iZXIgMjAxNSAxNjoxMg0K
PiA+ID4gPiBUaGUgeDg2IGNwdXMgd2lsbCBhbHNvIGRvIDMyYml0IHdpZGUgcm13IGN5Y2xlcyBm
b3IgdGhlICdiaXQnIG9wZXJhdGlvbnMuDQo+ID4gPg0KPiA+ID4gVGhhdCdzIGRpZmZlcmVudDog
aXQncyBhbiBhdG9taWMgUk1XIG9wZXJhdGlvbi4gIFRoZSBwcm9ibGVtIHdpdGggdGhlDQo+ID4g
PiBhbHBoYSB3YXMgdGhhdCB0aGUgb3BlcmF0aW9uIHdhc24ndCBhdG9taWMgKG1lYW5pbmcgdGhh
dCBpdCBjYW4ndCBiZQ0KPiA+ID4gaW50ZXJydXB0ZWQgYW5kIG5vIGludGVybWVkaWF0ZSBvdXRw
dXQgc3RhdGVzIGFyZSB2aXNpYmxlKS4NCj4gPg0KPiA+IEl0IGlzIG9ubHkgYXRvbWljIGlmIHBy
ZWZpeGVkIGJ5IHRoZSAnbG9jaycgcHJlZml4Lg0KPiA+IE5vcm1hbGx5IHRoZSByZWFkIGFuZCB3
cml0ZSBhcmUgc2VwYXJhdGUgYnVzIGN5Y2xlcy4NCj4gDQo+IFRoZSBlc3NlbnRpYWwgcG9pbnQg
aXMgdGhhdCB4ODYgaGFzIGF0b21pYyBiaXQgb3BzIGFuZCBieXRlIHdyaXRlcy4NCj4gRWFybHkg
YWxwaGEgZGlkIG5vdC4NCg0KRWFybHkgYWxwaGEgZGlkbid0IGhhdmUgYW55IGJ5dGUgYWNjZXNz
ZXMuDQoNCk9uIHg4NiBpZiB5b3UgaGF2ZSB0aGUgZm9sbG93aW5nOg0KCXN0cnVjdCB7DQoJCWNo
YXIgIGE7DQoJCXZvbGF0aWxlIGNoYXIgYjsNCgl9ICpmb287DQoJZm9vLT5hIHw9IDQ7DQoNClRo
ZSBjb21waWxlciBpcyBsaWtlbHkgdG8gZ2VuZXJhdGUgYSAnYmlzICM0LCAwKHJieCknIChvciBz
aW1pbGFyKQ0KYW5kIHRoZSBjcHUgd2lsbCBkbyB0d28gMzJiaXQgbWVtb3J5IGN5Y2xlcyB0aGF0
IHJlYWQgYW5kIHdyaXRlDQp0aGUgJ3ZvbGF0aWxlJyBmaWVsZCAnYicuDQooZ2NjIGRlZmluaXRl
bHkgdXNlZCB0byBkbyB0aGlzLi4uKQ0KDQpBIGxvdCBvZiBmaWVsZHMgd2VyZSBtYWRlIDMyYml0
IChhbmQgcHJvYmFibHkgbm90IGJpdGZpZWxkcykgaW4gdGhlIGxpbnV4DQprZXJuZWwgdHJlZSBh
IHllYXIgb3IgdHdvIGFnbyB0byBhdm9pZCB0aGlzIHZlcnkgcHJvYmxlbS4NCg0KPiA+ID4gPiBZ
b3Ugc3RpbGwgaGF2ZSB0byBlbnN1cmUgdGhlIGNvbXBpbGVyIGRvZXNuJ3QgZG8gd2lkZXIgcm13
IGN5Y2xlcy4NCj4gPiA+ID4gSSBiZWxpZXZlIHRoZSByZWNlbnQgdmVyc2lvbnMgb2YgZ2NjIHdv
bid0IGRvIHdpZGVyIGFjY2Vzc2VzIGZvciB2b2xhdGlsZSBkYXRhLg0KPiA+ID4NCj4gPiA+IEkg
ZG9uJ3QgdW5kZXJzdGFuZCB0aGlzIGNvbW1lbnQuICBZb3Ugc2VlbSB0byBiZSBpbXBseWluZyBn
Y2Mgd291bGQgZG8gYQ0KPiA+ID4gNjQgYml0IFJNVyBmb3IgYSAzMiBiaXQgc3RvcmUgLi4uIHRo
YXQgd291bGQgYmUgZGFmdCB3aGVuIGEgc2luZ2xlDQo+ID4gPiBpbnN0cnVjdGlvbiBleGlzdHMg
dG8gcGVyZm9ybSB0aGUgb3BlcmF0aW9uIG9uIGFsbCBhcmNoaXRlY3R1cmVzLg0KPiA+DQo+ID4g
UmVhZCB0aGUgb2JqZWN0IGNvZGUgYW5kIHdlZXAuLi4NCj4gPiBJdCBpcyBtb3N0IGxpa2VseSB0
byBoYXBwZW4gZm9yIG9wZXJhdGlvbnMgdGhhdCBhcmUgcm13IChlZyBiaXQgc2V0KS4NCj4gPiBG
b3IgaW5zdGFuY2UgdGhlIGFybSBjcHUgaGFzIGxpbWl0ZWQgb2Zmc2V0cyBmb3IgMTZiaXQgYWNj
ZXNzZXMsIGZvcg0KPiA+IG5vcm1hbCBzdHJ1Y3R1cmVzIHRoZSBjb21waWxlciBpcyBsaWtlbHkg
dG8gdXNlIGEgMzJiaXQgcm13IHNlcXVlbmNlDQo+ID4gZm9yIGEgMTZiaXQgZmllbGQgdGhhdCBo
YXMgYSBsYXJnZSBvZmZzZXQuDQo+ID4gVGhlIEMgbGFuZ3VhZ2UgYWxsb3dzIHRoZSBjb21waWxl
ciB0byBkbyBpdCBmb3IgYW55IGFjY2VzcyAoSUlSQyBpbmNsdWRpbmcNCj4gPiB2b2xhdGlsZXMp
Lg0KPiANCj4gSSB0aGluayB5b3UgbWlnaHQgYmUgY29uZnVzaW5nIGRpZmZlcmVudCB0aGluZ3Mu
ICBNb3N0IFJJU0MgQ1BVcyBjYW4ndA0KPiBkbyAzMiBiaXQgc3RvcmUgaW1tZWRpYXRlcyBiZWNh
dXNlIHRoZXJlIGFyZW4ndCBlbm91Z2ggYml0cyBpbiB0aGVpcg0KPiBhcnNlbmFsLCBzbyB0aGV5
IHRlbmQgdG8gc3BsaXQgMzIgYml0IGxvYWRzIGludG8gYSBsZWZ0IGFuZCByaWdodCBwYXJ0DQo+
IChmaXJzdCB0aGUgdG9wIHRoZW4gdGhlIG9mZnNldCkuICBUaGlzIChhbmQgb3RoZXIgdGhpbmdz
KSBhcmUgbW9zdGx5DQo+IHdoYXQgeW91IHNlZSBpbiBjb2RlLiAgSG93ZXZlciwgMzIgYml0IHJl
Z2lzdGVyIHN0b3JlcyBhcmUgc3RpbGwgYXRvbWljLA0KPiB3aGljaCBpcyBhbGwgd2UgcmVxdWly
ZS4gIEl0J3Mgbm90IHJlYWxseSB0aGUgY29tcGlsZXIncyBmYXVsdCwgaXQncw0KPiBtb3N0bHkg
YW4gYXJjaGl0ZWN0dXJhbCBsaW1pdGF0aW9uLg0KDQpObywgSSdtIG5vdCB0YWxraW5nIGFib3V0
IGhvdyAzMmJpdCBjb25zdGFudHMgYXJlIGdlbmVyYXRlZC4NCkknbSB0YWxraW5nIGFib3V0IHN0
cnVjdHVyZSBvZmZzZXRzLg0KDQoJRGF2aWQNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
