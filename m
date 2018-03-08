Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 238086B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 10:56:35 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id g186so79587qkd.16
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 07:56:35 -0800 (PST)
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com. [15.233.44.25])
        by mx.google.com with ESMTPS id l12si16279580qtb.446.2018.03.08.07.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 07:56:33 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 1/2] mm/vmalloc: Add interfaces to free unused page table
Date: Thu, 8 Mar 2018 15:56:30 +0000
Message-ID: <1520527285.2693.56.camel@hpe.com>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
	 <20180307183227.17983-2-toshi.kani@hpe.com>
	 <20180308040016.GB9082@bombadil.infradead.org>
In-Reply-To: <20180308040016.GB9082@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <07566710C6CDB64EB527EA8B1AD27212@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "willy@infradead.org" <willy@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko,
 Michal" <mhocko@suse.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gV2VkLCAyMDE4LTAzLTA3IGF0IDIwOjAwIC0wODAwLCBNYXR0aGV3IFdpbGNveCB3cm90ZToN
Cj4gT24gV2VkLCBNYXIgMDcsIDIwMTggYXQgMTE6MzI6MjZBTSAtMDcwMCwgVG9zaGkgS2FuaSB3
cm90ZToNCj4gPiArLyoqDQo+ID4gKyAqIHB1ZF9mcmVlX3BtZF9wYWdlIC0gY2xlYXIgcHVkIGVu
dHJ5IGFuZCBmcmVlIHBtZCBwYWdlDQo+ID4gKyAqDQo+ID4gKyAqIFJldHVybnMgMSBvbiBzdWNj
ZXNzIGFuZCAwIG9uIGZhaWx1cmUgKHB1ZCBub3QgY2xlYXJlZCkuDQo+ID4gKyAqLw0KPiA+ICtp
bnQgcHVkX2ZyZWVfcG1kX3BhZ2UocHVkX3QgKnB1ZCkNCj4gPiArew0KPiA+ICsJcmV0dXJuIHB1
ZF9ub25lKCpwdWQpOw0KPiA+ICt9DQo+IA0KPiBXb3VsZG4ndCBpdCBiZSBjbGVhcmVyIGlmIHlv
dSByZXR1cm5lZCAnYm9vbCcgaW5zdGVhZCBvZiAnaW50JyBoZXJlPw0KDQpJIHRob3VnaHQgYWJv
dXQgaXQgYW5kIGRlY2lkZWQgdG8gdXNlICdpbnQnIHNpbmNlIGFsbCBvdGhlciBwdWQvcG1kL3B0
ZQ0KaW50ZXJmYWNlcywgc3VjaCBhcyBwdWRfbm9uZSgpIGFib3ZlLCB1c2UgJ2ludCcuDQoNCj4g
QWxzbyB5b3UgZGlkbid0IGRvY3VtZW50IHRoZSBwdWQgcGFyYW1ldGVyLCBub3IgdXNlIHRoZSBh
cHByb3ZlZCBmb3JtDQo+IGZvciBkb2N1bWVudGluZyB0aGUgcmV0dXJuIHR5cGUsIG5vciB0aGUg
Y2FsbGluZyBjb250ZXh0LiAgU28gSSB3b3VsZA0KPiBoYXZlIHdyaXR0ZW4gaXQgb3V0IGxpa2Ug
dGhpczoNCj4gDQo+IC8qKg0KPiAgKiBwdWRfZnJlZV9wbWRfcGFnZSAtIENsZWFyIHB1ZCBlbnRy
eSBhbmQgZnJlZSBwbWQgcGFnZS4NCj4gICogQHB1ZDogUG9pbnRlciB0byBhIFBVRC4NCj4gICoN
Cj4gICogQ29udGV4dDogQ2FsbGVyIHNob3VsZCBob2xkIG1tYXBfc2VtIHdyaXRlLWxvY2tlZC4N
Cj4gICogUmV0dXJuOiAldHJ1ZSBpZiBjbGVhcmluZyB0aGUgZW50cnkgc3VjY2VlZGVkLg0KPiAg
Ki8NCg0KV2lsbCBkby4NCg0KVGhhbmtzIQ0KLVRvc2hpDQo=
