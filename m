Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B314F6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 14:56:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j25-v6so1941245pfi.20
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 11:56:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w2-v6si4451386pgq.581.2018.06.21.11.56.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 11:56:15 -0700 (PDT)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH 0/3] KASLR feature to randomize each loadable module
Date: Thu, 21 Jun 2018 18:56:13 +0000
Message-ID: <1529607389.29548.198.camel@intel.com>
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
	 <CAGXu5jLt8Zv-p=9J590WFppc3O6LWrAVdi-xtU7r_8f4j0XeRg@mail.gmail.com>
In-Reply-To: <CAGXu5jLt8Zv-p=9J590WFppc3O6LWrAVdi-xtU7r_8f4j0XeRg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D28BD85D7D013B418334AAC8068AE927@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "keescook@chromium.org" <keescook@chromium.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Van De
 Ven, Arjan" <arjan.van.de.ven@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "Accardi, Kristen C" <kristen.c.accardi@intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

T24gV2VkLCAyMDE4LTA2LTIwIGF0IDE1OjMzIC0wNzAwLCBLZWVzIENvb2sgd3JvdGU6DQo+ID4g
VGhlIG5ldyBfX3ZtYWxsb2Nfbm9kZV90cnlfYWRkciBmdW5jdGlvbiB1c2VzIHRoZSBleGlzdGlu
ZyBmdW5jdGlvbg0KPiA+IF9fdm1hbGxvY19ub2RlX3JhbmdlLCBpbiBvcmRlciB0byBpbnRyb2R1
Y2UgdGhpcyBhbGdvcml0aG0gd2l0aCB0aGUNCj4gPiBsZWFzdA0KPiA+IGludmFzaXZlIGNoYW5n
ZS4gVGhlIHNpZGUgZWZmZWN0IGlzIHRoYXQgZWFjaCB0aW1lIHRoZXJlIGlzIGENCj4gPiBjb2xs
aXNpb24gd2hlbg0KPiA+IHRyeWluZyB0byBhbGxvY2F0ZSBpbiB0aGUgcmFuZG9tIGFyZWEgYSBU
TEIgZmx1c2ggd2lsbCBiZQ0KPiA+IHRyaWdnZXJlZC4gVGhlcmUgaXMNCj4gPiBhIG1vcmUgY29t
cGxleCwgbW9yZSBlZmZpY2llbnQgaW1wbGVtZW50YXRpb24gdGhhdCBjYW4gYmUgdXNlZA0KPiA+
IGluc3RlYWQgaWYNCj4gPiB0aGVyZSBpcyBpbnRlcmVzdCBpbiBpbXByb3ZpbmcgcGVyZm9ybWFu
Y2UuDQo+IFRoZSBvbmx5IHRpbWUgd2hlbiBtb2R1bGUgbG9hZGluZyBzcGVlZCBpcyBub3RpY2Vh
YmxlLCBJIHdvdWxkIHRoaW5rLA0KPiB3b3VsZCBiZSBib290IHRpbWUuIEhhdmUgeW91IGRvbmUg
YW55IGJvb3QgdGltZSBkZWx0YSBhbmFseXNpcz8gSQ0KPiB3b3VsZG4ndCBleHBlY3QgaXQgdG8g
Y2hhbmdlIGhhcmRseSBhdCBhbGwsIGJ1dCBpdCdzIHByb2JhYmx5IGEgZ29vZA0KPiBpZGVhIHRv
IGFjdHVhbGx5IHRlc3QgaXQuIDopDQoNClRoYW5rcywgSSdsbCBkbyBzb21lIHRlc3RzLg0KDQo+
IEFsc286IGNhbiB0aGlzIGJlIGdlbmVyYWxpemVkIGZvciB1c2Ugb24gb3RoZXIgS0FTTFJlZCBh
cmNoaXRlY3R1cmVzPw0KPiBGb3IgZXhhbXBsZSwgSSBrbm93IHRoZSBhcm02NCBtb2R1bGUgcmFu
ZG9taXphdGlvbiBpcyBwcmV0dHkgc2ltaWxhcg0KPiB0byB4ODYuDQoNCkkgc3RhcnRlZCBpbiB0
aGUgeDg2L2tlcm5lbC9tb2R1bGUuYyBiZWNhdXNlIHRoYXQgd2FzIHdoZXJlIHRoZQ0KZXhpc3Rp
bmcgaW1wbGVtZW50YXRpb24gd2FzLCBidXQgSSBkb24ndCBrbm93IG9mIGFueSByZWFzb24gd2h5
DQppdMKgY291bGQgbm90IGFwcGx5IHRvIG90aGVyIGFyY2hpdGVjdHVyZXMgaW4gZ2VuZXJhbC4N
Cg0KVGhlIHJhbmRvbW5lc3MgZXN0aW1hdGVzIHdvdWxkIGJlIGRpZmZlcmVudCBpZiBtb2R1bGUg
c2l6ZSBwcm9iYWJpbGl0eQ0KZGlzdHJpYnV0aW9uLCBtb2R1bGUgc3BhY2Ugc2l6ZSBvciBtb2R1
bGUgYWxpZ25tZW50IGFyZSBkaWZmZXJlbnQuDQoNCg==
