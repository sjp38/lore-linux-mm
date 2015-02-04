Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id B88C86B00AC
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 16:08:37 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so31769220wib.1
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 13:08:37 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id da9si5385940wjc.125.2015.02.04.13.08.35
        for <linux-mm@kvack.org>;
        Wed, 04 Feb 2015 13:08:36 -0800 (PST)
From: Daniel Sanders <Daniel.Sanders@imgtec.com>
Subject: RE: [PATCH 1/5] LLVMLinux: Correct size_index table before
 replacing the bootstrap kmem_cache_node.
Date: Wed, 4 Feb 2015 21:08:33 +0000
Message-ID: <E484D272A3A61B4880CDF2E712E9279F4591C476@hhmail02.hh.imgtec.org>
References: <1422970639-7922-1-git-send-email-daniel.sanders@imgtec.com>
	<1422970639-7922-2-git-send-email-daniel.sanders@imgtec.com>
	<54D27403.90000@iki.fi>
	<E484D272A3A61B4880CDF2E712E9279F4591C3EC@hhmail02.hh.imgtec.org>
 <CAOJsxLF453qWJitGGjn+gMcJwXdXo4wLtmGzhVYJ3j5xOYNHWg@mail.gmail.com>
In-Reply-To: <CAOJsxLF453qWJitGGjn+gMcJwXdXo4wLtmGzhVYJ3j5xOYNHWg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBwZW5iZXJnQGdtYWlsLmNvbSBb
bWFpbHRvOnBlbmJlcmdAZ21haWwuY29tXSBPbiBCZWhhbGYgT2YNCj4gUGVra2EgRW5iZXJnDQo+
IFNlbnQ6IDA0IEZlYnJ1YXJ5IDIwMTUgMjA6NDINCj4gVG86IERhbmllbCBTYW5kZXJzDQo+IENj
OiBDaHJpc3RvcGggTGFtZXRlcjsgRGF2aWQgUmllbnRqZXM7IEpvb25zb28gS2ltOyBBbmRyZXcg
TW9ydG9uOyBsaW51eC0NCj4gbW1Aa3ZhY2sub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwu
b3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggMS81XSBMTFZNTGludXg6IENvcnJlY3Qgc2l6ZV9p
bmRleCB0YWJsZSBiZWZvcmUNCj4gcmVwbGFjaW5nIHRoZSBib290c3RyYXAga21lbV9jYWNoZV9u
b2RlLg0KPiANCj4gT24gV2VkLCBGZWIgNCwgMjAxNSBhdCAxMDozOCBQTSwgRGFuaWVsIFNhbmRl
cnMNCj4gPERhbmllbC5TYW5kZXJzQGltZ3RlYy5jb20+IHdyb3RlOg0KPiA+IEkgZG9uJ3QgYmVs
aWV2ZSB0aGUgYnVnIHRvIGJlIExMVk0gc3BlY2lmaWMgYnV0IEdDQyBkb2Vzbid0IG5vcm1hbGx5
DQo+IGVuY291bnRlciB0aGUgcHJvYmxlbS4gSSBoYXZlbid0IGJlZW4gYWJsZSB0byBpZGVudGlm
eSBleGFjdGx5IHdoYXQgR0NDIGlzDQo+IGRvaW5nIGJldHRlciAocHJvYmFibHkgaW5saW5pbmcp
IGJ1dCBpdCBzZWVtcyB0aGF0IEdDQyBpcyBtYW5hZ2luZyB0bw0KPiBvcHRpbWl6ZSAgdG8gdGhl
IHBvaW50IHRoYXQgaXQgZWxpbWluYXRlcyB0aGUgcHJvYmxlbWF0aWMgYWxsb2NhdGlvbnMuIFRo
aXMNCj4gdGhlb3J5IGlzIHN1cHBvcnRlZCBieSB0aGUgZmFjdCB0aGF0IEdDQyBjYW4gYmUgbWFk
ZSB0byBmYWlsIGluIHRoZSBzYW1lIHdheQ0KPiBieSBjaGFuZ2luZyBpbmxpbmUsIF9faW5saW5l
LCBfX2lubGluZV9fLCBhbmQgX19hbHdheXNfaW5saW5lIGluDQo+IGluY2x1ZGUvbGludXgvY29t
cGlsZXItZ2NjLmggc3VjaCB0aGF0IHRoZXkgZG9uJ3QgYWN0dWFsbHkgaW5saW5lIHRoaW5ncy4N
Cj4gDQo+IE9LLCBtYWtlcyBzZW5zZS4gUGxlYXNlIGluY2x1ZGUgdGhhdCBleHBsYW5hdGlvbiBp
biB0aGUgY2hhbmdlbG9nIGFuZA0KPiBkcm9wIHVzZSBwcm9wZXIgInNsYWIiIHByZWZpeCBpbnN0
ZWFkIG9mIHRoZSBjb25mdXNpbmcgIkxMVk1MaW51eCINCj4gcHJlZml4IGluIHRoZSBzdWJqZWN0
IGxpbmUuDQo+IA0KPiAtIFBla2thDQoNClN1cmUuIEkndmUganVzdCB1cGRhdGVkIHRoZSBwYXRj
aCB3aXRoIHRob3NlIGNoYW5nZXMuDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
