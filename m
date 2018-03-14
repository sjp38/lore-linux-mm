Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 605B96B0007
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 15:38:58 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c41-v6so1860518plj.10
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 12:38:58 -0700 (PDT)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id v6-v6si2425405plg.618.2018.03.14.12.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 12:38:57 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 2/2] x86/mm: remove pointless checks in vmalloc_fault
Date: Wed, 14 Mar 2018 19:38:51 +0000
Message-ID: <1521056327.2693.138.camel@hpe.com>
References: <20180313170347.3829-1-toshi.kani@hpe.com>
	 <20180313170347.3829-3-toshi.kani@hpe.com>
	 <alpine.DEB.2.21.1803142024540.1946@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1803142024540.1946@nanos.tec.linutronix.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <95D0813A8DE3224DAA8F43FA8237DC15@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "gratian.crisan@ni.com" <gratian.crisan@ni.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>

T24gV2VkLCAyMDE4LTAzLTE0IGF0IDIwOjI3ICswMTAwLCBUaG9tYXMgR2xlaXhuZXIgd3JvdGU6
DQo+IE9uIFR1ZSwgMTMgTWFyIDIwMTgsIFRvc2hpIEthbmkgd3JvdGU6DQo+IA0KPiA+IHZtYWxs
b2NfZmF1bHQoKSBzZXRzIHVzZXIncyBwZ2Qgb3IgcDRkIGZyb20gdGhlIGtlcm5lbCBwYWdlIHRh
YmxlLg0KPiA+IE9uY2UgaXQncyBzZXQsIGFsbCB0YWJsZXMgdW5kZXJuZWF0aCBhcmUgaWRlbnRp
Y2FsLiBUaGVyZSBpcyBubyBwb2ludA0KPiA+IG9mIGZvbGxvd2luZyB0aGUgc2FtZSBwYWdlIHRh
YmxlIHdpdGggdHdvIHNlcGFyYXRlIHBvaW50ZXJzIGFuZCBtYWtlcw0KPiA+IHN1cmUgdGhleSBz
ZWUgdGhlIHNhbWUgd2l0aCBCVUcoKS4NCj4gPiANCj4gPiBSZW1vdmUgdGhlIHBvaW50bGVzcyBj
aGVja3MgaW4gdm1hbGxvY19mYXVsdCgpLiBBbHNvIHJlbmFtZSB0aGUga2VybmVsDQo+ID4gcGdk
L3A0ZCBwb2ludGVycyB0byBwZ2Rfay9wNGRfayBzbyB0aGF0IHRoZWlyIG5hbWVzIGFyZSBjb25z
aXN0ZW50IGluDQo+ID4gdGhlIGZpbGUuDQo+IA0KPiBJIGhhdmUgbm8gaWRlYSB0byB3aGljaCBi
cmFuY2ggdGhpcyBtaWdodCBhcHBseS4gVGhlIGZpcnN0IHBhdGNoIGFwcGxpZXMNCj4gY2xlYW5s
eSBvbiBsaW51cyBoZWFkLCBidXQgdGhpcyBvbmUgZmFpbHMgaW4gaHVuayAjMiBvbiBldmVyeXRo
aW5nIEkNCj4gdHJpZWQuIENhbiB5b3UgcGxlYXNlIGNoZWNrPw0KDQpTb3JyeSBmb3IgdGhlIHRy
b3VibGUuIFRoZSBwYXRjaGVzIGFyZSBiYXNlZCBvbiBsaW51cyBoZWFkLiBJIGp1c3QgdHJpZWQN
CmFuZCB0aGV5IGFwcGxpZWQgY2xlYW4gdG8gbWUuLi4gDQoNClRoYW5rcywNCi1Ub3NoaQ0K
