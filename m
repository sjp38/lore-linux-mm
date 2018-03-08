Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06D216B0007
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 18:27:38 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id g186so1005259qkd.16
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 15:27:38 -0800 (PST)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id c38si1295758qtc.442.2018.03.08.15.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 15:27:37 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 1/2] mm/vmalloc: Add interfaces to free unused page table
Date: Thu, 8 Mar 2018 23:27:10 +0000
Message-ID: <1520554326.2693.122.camel@hpe.com>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
	 <20180307183227.17983-2-toshi.kani@hpe.com>
	 <20180308040016.GB9082@bombadil.infradead.org>
	 <1520527285.2693.56.camel@hpe.com>
	 <20180308220708.GA29073@bombadil.infradead.org>
In-Reply-To: <20180308220708.GA29073@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <F01D6BD9CA7BAF4DA5EA152F91C9C4C6@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "willy@infradead.org" <willy@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko,
 Michal" <mhocko@suse.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gVGh1LCAyMDE4LTAzLTA4IGF0IDE0OjA3IC0wODAwLCBNYXR0aGV3IFdpbGNveCB3cm90ZToN
Cj4gT24gVGh1LCBNYXIgMDgsIDIwMTggYXQgMDM6NTY6MzBQTSArMDAwMCwgS2FuaSwgVG9zaGkg
d3JvdGU6DQo+ID4gT24gV2VkLCAyMDE4LTAzLTA3IGF0IDIwOjAwIC0wODAwLCBNYXR0aGV3IFdp
bGNveCB3cm90ZToNCj4gPiA+IE9uIFdlZCwgTWFyIDA3LCAyMDE4IGF0IDExOjMyOjI2QU0gLTA3
MDAsIFRvc2hpIEthbmkgd3JvdGU6DQo+ID4gPiA+ICsvKioNCj4gPiA+ID4gKyAqIHB1ZF9mcmVl
X3BtZF9wYWdlIC0gY2xlYXIgcHVkIGVudHJ5IGFuZCBmcmVlIHBtZCBwYWdlDQo+ID4gPiA+ICsg
Kg0KPiA+ID4gPiArICogUmV0dXJucyAxIG9uIHN1Y2Nlc3MgYW5kIDAgb24gZmFpbHVyZSAocHVk
IG5vdCBjbGVhcmVkKS4NCj4gPiA+ID4gKyAqLw0KPiA+ID4gPiAraW50IHB1ZF9mcmVlX3BtZF9w
YWdlKHB1ZF90ICpwdWQpDQo+ID4gPiA+ICt7DQo+ID4gPiA+ICsJcmV0dXJuIHB1ZF9ub25lKCpw
dWQpOw0KPiA+ID4gPiArfQ0KPiA+ID4gDQo+ID4gPiBXb3VsZG4ndCBpdCBiZSBjbGVhcmVyIGlm
IHlvdSByZXR1cm5lZCAnYm9vbCcgaW5zdGVhZCBvZiAnaW50JyBoZXJlPw0KPiA+IA0KPiA+IEkg
dGhvdWdodCBhYm91dCBpdCBhbmQgZGVjaWRlZCB0byB1c2UgJ2ludCcgc2luY2UgYWxsIG90aGVy
IHB1ZC9wbWQvcHRlDQo+ID4gaW50ZXJmYWNlcywgc3VjaCBhcyBwdWRfbm9uZSgpIGFib3ZlLCB1
c2UgJ2ludCcuDQo+IA0KPiBUaGVzZSBpbnRlcmZhY2VzIHdlcmUgaW50cm9kdWNlZCBiZWZvcmUg
d2UgaGFkIGJvb2wgLi4uIEkgc3VzcGVjdCBub2JvZHkncw0KPiB0YWtlbiB0aGUgdGltZSB0byBn
byB0aHJvdWdoIGFuZCBjb252ZXJ0IHRoZW0gYWxsLg0KDQpJIHNlZS4gIFNpbmNlIHRoaXMgcGF0
Y2hzZXQgYWxyZWFkeSBjaGFuZ2VzIGNvcmUsIGFybSBhbmQgeDg2LCBhbmQgd2lsbA0KYmUgYmFj
ayBwb3J0ZWQgdG8gc3RhYmxlcy4gIFNvLCBpZiB5b3UgZG8gbm90IG1pbmQsIEknZCBsaWtlIHRv
IGxlYXZlIGl0DQpjb25zaXN0ZW50IHdpdGggb3RoZXJzIHdpdGggJ2ludCcsIGFuZCBtYWtlIHRo
ZSBmb290c3RlcCBtaW5pbXVtLg0KDQpUaGFua3MsDQotVG9zaGkNCg==
