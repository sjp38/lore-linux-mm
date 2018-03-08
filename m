Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A105A6B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 14:30:27 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id p6so3483347oic.9
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 11:30:27 -0800 (PST)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id e130si5742513oih.18.2018.03.08.11.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 11:30:26 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 1/2] mm/vmalloc: Add interfaces to free unused page table
Date: Thu, 8 Mar 2018 19:30:23 +0000
Message-ID: <1520540118.2693.103.camel@hpe.com>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
	 <20180307183227.17983-2-toshi.kani@hpe.com>
	 <20180308180446.GF14918@arm.com>
In-Reply-To: <20180308180446.GF14918@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <3F44F0EB15826948A3A7A51792F1AC7A@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "will.deacon@arm.com" <will.deacon@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <mhocko@suse.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gVGh1LCAyMDE4LTAzLTA4IGF0IDE4OjA0ICswMDAwLCBXaWxsIERlYWNvbiB3cm90ZToNCiA6
DQo+ID4gZGlmZiAtLWdpdCBhL2xpYi9pb3JlbWFwLmMgYi9saWIvaW9yZW1hcC5jDQo+ID4gaW5k
ZXggYjgwOGEzOTBlNGMzLi41NGU1YmJhYTMyMDAgMTAwNjQ0DQo+ID4gLS0tIGEvbGliL2lvcmVt
YXAuYw0KPiA+ICsrKyBiL2xpYi9pb3JlbWFwLmMNCj4gPiBAQCAtOTEsNyArOTEsOCBAQCBzdGF0
aWMgaW5saW5lIGludCBpb3JlbWFwX3BtZF9yYW5nZShwdWRfdCAqcHVkLCB1bnNpZ25lZCBsb25n
IGFkZHIsDQo+ID4gIA0KPiA+ICAJCWlmIChpb3JlbWFwX3BtZF9lbmFibGVkKCkgJiYNCj4gPiAg
CQkgICAgKChuZXh0IC0gYWRkcikgPT0gUE1EX1NJWkUpICYmDQo+ID4gLQkJICAgIElTX0FMSUdO
RUQocGh5c19hZGRyICsgYWRkciwgUE1EX1NJWkUpKSB7DQo+ID4gKwkJICAgIElTX0FMSUdORUQo
cGh5c19hZGRyICsgYWRkciwgUE1EX1NJWkUpICYmDQo+ID4gKwkJICAgIHBtZF9mcmVlX3B0ZV9w
YWdlKHBtZCkpIHsNCj4gDQo+IEkgZmluZCBpdCBhIGJpdCB3ZWlyZCB0aGF0IHdlJ3JlIHBvc3Rw
b25pbmcgdGhpcyB0byB0aGUgc3Vic2VxdWVudCBtYXAuIElmDQo+IHdlIHdhbnQgdG8gYWRkcmVz
cyB0aGUgYnJlYWstYmVmb3JlLW1ha2UgaXNzdWUgdGhhdCB3YXMgY2F1c2luZyBhIHBhbmljIG9u
DQo+IGFybTY0LCB0aGVuIEkgdGhpbmsgaXQgd291bGQgYmUgYmV0dGVyIHRvIGRvIHRoaXMgb24g
dGhlIHVubWFwIHBhdGggdG8gYXZvaWQNCj4gZHVwbGljYXRpbmcgVExCIGludmFsaWRhdGlvbi4N
Cg0KSGkgV2lsbCwNCg0KWWVzLCBJIHN0YXJ0ZWQgbG9va2luZyBpbnRvIGRvaW5nIGl0IHRoZSB1
bm1hcCBwYXRoLCBidXQgZm91bmQgdGhlDQpmb2xsb3dpbmcgaXNzdWVzOg0KDQogLSBUaGUgaW91
bm1hcCgpIHBhdGggaXMgc2hhcmVkIHdpdGggdnVubWFwKCkuICBTaW5jZSB2bWFwKCkgb25seQ0K
c3VwcG9ydHMgcHRlIG1hcHBpbmdzLCBtYWtpbmcgdnVubWFwKCkgdG8gZnJlZSBwdGUgcGFnZXMg
aXMgYW4gb3ZlcmhlYWQNCmZvciByZWd1bGFyIHZtYXAgdXNlcnMgYXMgdGhleSBkbyBub3QgbmVl
ZCBwdGUgcGFnZXMgZnJlZWQgdXAuDQogLSBDaGVja2luZyB0byBzZWUgaWYgYWxsIGVudHJpZXMg
aW4gYSBwdGUgcGFnZSBhcmUgY2xlYXJlZCBpbiB0aGUgdW5tYXANCnBhdGggaXMgcmFjeSwgYW5k
IHNlcmlhbGl6aW5nIHRoaXMgY2hlY2sgaXMgZXhwZW5zaXZlLg0KIC0gVGhlIHVubWFwIHBhdGgg
Y2FsbHMgZnJlZV92bWFwX2FyZWFfbm9mbHVzaCgpIHRvIGRvIGxhenkgVExCIHB1cmdlcy4NCkNs
ZWFyaW5nIGEgcHVkL3BtZCBlbnRyeSBiZWZvcmUgdGhlIGxhenkgVExCIHB1cmdlcyBuZWVkcyBl
eHRyYSBUTEINCnB1cmdlLg0KDQpIZW5jZSwgSSBkZWNpZGVkIHRvIHBvc3Rwb25lIGFuZCBkbyBp
dCBpbiB0aGUgaW9yZW1hcCBwYXRoIHdoZW4gYQ0KcHVkL3BtZCBtYXBwaW5nIGlzIHNldC4gIFRo
ZSAiYnJlYWsiIG9uIGFybTY0IGhhcHBlbnMgd2hlbiB5b3UgdXBkYXRlIGENCnBtZCBlbnRyeSB3
aXRob3V0IHB1cmdpbmcgaXQuICBTbywgdGhlIHVubWFwIHBhdGggaXMgbm90IGJyb2tlbi4gIEkN
CnVuZGVyc3RhbmQgdGhhdCBhcm02NCBtYXkgbmVlZCBleHRyYSBUTEIgcHVyZ2UgaW4gcG1kX2Zy
ZWVfcHRlX3BhZ2UoKSwNCmJ1dCBpdCBsaW1pdHMgdGhpcyBvdmVyaGVhZCBvbmx5IHdoZW4gaXQg
c2V0cyB1cCBhIHB1ZC9wbWQgbWFwcGluZy4NCg0KVGhhbmtzLA0KLVRvc2hpDQo=
