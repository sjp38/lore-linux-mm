Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 490146B026F
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 12:02:01 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id b1-v6so5674990otf.22
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 09:02:01 -0700 (PDT)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id s3-v6si3140876oif.109.2018.06.29.09.01.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 09:01:58 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v4 2/3] ioremap: Update pgtable free interfaces with addr
Date: Fri, 29 Jun 2018 16:01:54 +0000
Message-ID: <1530287995.14039.361.camel@hpe.com>
References: <20180627141348.21777-1-toshi.kani@hpe.com>
	 <20180627141348.21777-3-toshi.kani@hpe.com>
	 <20180627155632.GH30631@arm.com> <1530115885.14039.295.camel@hpe.com>
	 <20180629122358.GC17859@arm.com>
In-Reply-To: <20180629122358.GC17859@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <84DC9C22A8370C43990D4CEF85DFAAC7@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "will.deacon@arm.com" <will.deacon@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "joro@8bytes.org" <joro@8bytes.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gRnJpLCAyMDE4LTA2LTI5IGF0IDEzOjIzICswMTAwLCBXaWxsIERlYWNvbiB3cm90ZToNCj4g
SGkgVG9zaGksIFRob21hcywNCj4gDQo+IE9uIFdlZCwgSnVuIDI3LCAyMDE4IGF0IDA0OjEzOjIy
UE0gKzAwMDAsIEthbmksIFRvc2hpIHdyb3RlOg0KPiA+IE9uIFdlZCwgMjAxOC0wNi0yNyBhdCAx
Njo1NiArMDEwMCwgV2lsbCBEZWFjb24gd3JvdGU6DQo+ID4gPiBPbiBXZWQsIEp1biAyNywgMjAx
OCBhdCAwODoxMzo0N0FNIC0wNjAwLCBUb3NoaSBLYW5pIHdyb3RlOg0KPiA+ID4gPiBGcm9tOiBD
aGludGFuIFBhbmR5YSA8Y3BhbmR5YUBjb2RlYXVyb3JhLm9yZz4NCj4gPiA+ID4gDQo+ID4gPiA+
IFRoZSBmb2xsb3dpbmcga2VybmVsIHBhbmljIHdhcyBvYnNlcnZlZCBvbiBBUk02NCBwbGF0Zm9y
bSBkdWUgdG8gYSBzdGFsZQ0KPiA+ID4gPiBUTEIgZW50cnkuDQo+ID4gPiA+IA0KPiA+ID4gPiAg
MS4gaW9yZW1hcCB3aXRoIDRLIHNpemUsIGEgdmFsaWQgcHRlIHBhZ2UgdGFibGUgaXMgc2V0Lg0K
PiA+ID4gPiAgMi4gaW91bm1hcCBpdCwgaXRzIHB0ZSBlbnRyeSBpcyBzZXQgdG8gMC4NCj4gPiA+
ID4gIDMuIGlvcmVtYXAgdGhlIHNhbWUgYWRkcmVzcyB3aXRoIDJNIHNpemUsIHVwZGF0ZSBpdHMg
cG1kIGVudHJ5IHdpdGgNCj4gPiA+ID4gICAgIGEgbmV3IHZhbHVlLg0KPiA+ID4gPiAgNC4gQ1BV
IG1heSBoaXQgYW4gZXhjZXB0aW9uIGJlY2F1c2UgdGhlIG9sZCBwbWQgZW50cnkgaXMgc3RpbGwg
aW4gVExCLA0KPiA+ID4gPiAgICAgd2hpY2ggbGVhZHMgdG8gYSBrZXJuZWwgcGFuaWMuDQo+ID4g
PiA+IA0KPiA+ID4gPiBDb21taXQgYjZiZGI3NTE3YzNkICgibW0vdm1hbGxvYzogYWRkIGludGVy
ZmFjZXMgdG8gZnJlZSB1bm1hcHBlZCBwYWdlDQo+ID4gPiA+IHRhYmxlIikgaGFzIGFkZHJlc3Nl
ZCB0aGlzIHBhbmljIGJ5IGZhbGxpbmcgdG8gcHRlIG1hcHBpbmdzIGluIHRoZSBhYm92ZQ0KPiA+
ID4gPiBjYXNlIG9uIEFSTTY0Lg0KPiA+ID4gPiANCj4gPiA+ID4gVG8gc3VwcG9ydCBwbWQgbWFw
cGluZ3MgaW4gYWxsIGNhc2VzLCBUTEIgcHVyZ2UgbmVlZHMgdG8gYmUgcGVyZm9ybWVkDQo+ID4g
PiA+IGluIHRoaXMgY2FzZSBvbiBBUk02NC4NCj4gPiA+ID4gDQo+ID4gPiA+IEFkZCBhIG5ldyBh
cmcsICdhZGRyJywgdG8gcHVkX2ZyZWVfcG1kX3BhZ2UoKSBhbmQgcG1kX2ZyZWVfcHRlX3BhZ2Uo
KQ0KPiA+ID4gPiBzbyB0aGF0IFRMQiBwdXJnZSBjYW4gYmUgYWRkZWQgbGF0ZXIgaW4gc2VwcmF0
ZSBwYXRjaGVzLg0KPiA+ID4gDQo+ID4gPiBTbyBJIGFja2VkIHYxMyBvZiBDaGludGFuJ3Mgc2Vy
aWVzIHBvc3RlZCBoZXJlOg0KPiA+ID4gDQo+ID4gPiBodHRwOi8vbGlzdHMuaW5mcmFkZWFkLm9y
Zy9waXBlcm1haWwvbGludXgtYXJtLWtlcm5lbC8yMDE4LUp1bmUvNTgyOTUzLmh0bWwNCj4gPiA+
IA0KPiA+ID4gYW55IGNoYW5jZSB0aGlzIGxvdCBjb3VsZCBhbGwgYmUgbWVyZ2VkIHRvZ2V0aGVy
LCBwbGVhc2U/DQo+ID4gDQo+ID4gQ2hpbnRhbidzIHBhdGNoIDIvMyBhbmQgMy8zIGFwcGx5IGNs
ZWFubHkgb24gdG9wIG9mIG15IHNlcmllcy4gQ2FuIHlvdQ0KPiA+IHBsZWFzZSBjb29yZGluYXRl
IHdpdGggVGhvbWFzIG9uIHRoZSBsb2dpc3RpY3M/DQo+IA0KPiBTdXJlLiBJIGd1ZXNzIGhhdmlu
ZyB0aGlzIHNlcmllcyBvbiBhIGNvbW1vbiBicmFuY2ggdGhhdCBJIGNhbiBwdWxsIGludG8NCj4g
YXJtNjQgYW5kIGFwcGx5IENoaW50YW4ncyBvdGhlciBwYXRjaGVzIG9uIHRvcCB3b3VsZCB3b3Jr
Lg0KPiANCj4gSG93IGRvZXMgdGhhdCBzb3VuZD8NCg0KU2hvdWxkIHRoaXMgZ28gdGhydSAtbW0g
dHJlZSB0aGVuPw0KDQpBbmRyZXcsIFRob21hcywgd2hhdCBkbyB5b3UgdGhpbms/IA0KDQpUaGFu
a3MsDQotVG9zaGkNCg0KDQoNCg==
