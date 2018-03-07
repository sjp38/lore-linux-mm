Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E4F786B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 18:22:28 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b2so1572015pgt.6
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 15:22:28 -0800 (PST)
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com. [15.241.140.73])
        by mx.google.com with ESMTPS id l61-v6si13661977plb.95.2018.03.07.15.22.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 15:22:27 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 2/2] x86/mm: implement free pmd/pte page interfaces
Date: Wed, 7 Mar 2018 23:22:24 +0000
Message-ID: <1520467641.2693.52.camel@hpe.com>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
	 <20180307183227.17983-3-toshi.kani@hpe.com>
	 <20180307150127.1e09e9826e0f2c80ce42fa4d@linux-foundation.org>
In-Reply-To: <20180307150127.1e09e9826e0f2c80ce42fa4d@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <245FF568C40EC84CA7A33723FC319F6F@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko,
 Michal" <mhocko@suse.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gV2VkLCAyMDE4LTAzLTA3IGF0IDE1OjAxIC0wODAwLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0K
PiBPbiBXZWQsICA3IE1hciAyMDE4IDExOjMyOjI3IC0wNzAwIFRvc2hpIEthbmkgPHRvc2hpLmth
bmlAaHBlLmNvbT4gd3JvdGU6DQo+IA0KPiA+IEltcGxlbWVudCBwdWRfZnJlZV9wbWRfcGFnZSgp
IGFuZCBwbWRfZnJlZV9wdGVfcGFnZSgpIG9uIHg4Niwgd2hpY2gNCj4gPiBjbGVhciBhIGdpdmVu
IHB1ZC9wbWQgZW50cnkgYW5kIGZyZWUgdXAgbG93ZXIgbGV2ZWwgcGFnZSB0YWJsZShzKS4NCj4g
PiBBZGRyZXNzIHJhbmdlIGFzc29jaWF0ZWQgd2l0aCB0aGUgcHVkL3BtZCBlbnRyeSBtdXN0IGhh
dmUgYmVlbiBwdXJnZWQNCj4gPiBieSBJTlZMUEcuDQo+IA0KPiBPSywgbm93IHdlIGhhdmUgaW1w
bGVtZW50YXRpb25zIHdoaWNoIG1hdGNoIHRoZSBuYW1pbmcgOykgQWdhaW4sIGlzIGENCj4gY2M6
c3RhYmxlIHdhcnJhbnRlZD8NCg0KUmlnaHQuIFRoaXMgcGF0Y2ggMi8yIGZpeGVzIHRoZSBtZW1v
cnkgbGVhayBvbiB4ODYuDQoNCkZpeGVzOiBlNjFjZTZhZGU0MDRlICgibW06IGNoYW5nZSBpb3Jl
bWFwIHRvIHNldCB1cCBodWdlIEkvTyBtYXBwaW5ncyIpDQoNClBhdGNoIDEvMiBmaXhlcyB0aGUg
cGFuaWMgb24gYXJtNjQuDQoNCkZpeGVzOiAzMjQ0MjBiZjkxZjYwICgiYXJtNjQ6IGFkZCBzdXBw
b3J0IGZvciBpb3JlbWFwKCkgYmxvY2sgbWFwcGluZ3MiKQ0KDQo+IERvIHlvdSBoYXZlIGFueSBw
cmVmZXJlbmNlcy9zdWdnZXN0aW9ucyBhcyB0byB3aGljaCB0cmVlIHRoZXNlIHNob3VsZA0KPiBi
ZSBtZXJnZWQgdGhyb3VnaD8gIFlvdSdyZSBoaXR0aW5nIGNvcmUsIGFybSBhbmQgeDg2Lg0KDQpO
bywgSSBkbyBub3QgaGF2ZSBhbnkgcHJlZmVyZW5jZS4NCg0KVGhhbmtzLA0KLVRvc2hpDQoNCg==
