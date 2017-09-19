Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9226B0033
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 22:23:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a7so1162994pfj.3
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 19:23:52 -0700 (PDT)
Received: from smtpbg65.qq.com (smtpbg65.qq.com. [103.7.28.233])
        by mx.google.com with ESMTPS id 36si605497pgx.694.2017.09.18.19.23.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Sep 2017 19:23:50 -0700 (PDT)
From: "=?utf-8?B?6ZmI5Y2O5omN?=" <chenhc@lemote.com>
Subject: Re: [V5, 2/3] mm: dmapool: Align to ARCH_DMA_MINALIGN innon-coherent DMA mode
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Date: Tue, 19 Sep 2017 10:23:45 +0800
Message-ID: <tencent_27AD421B310F475224638DF3@qq.com>
References: <1505708548-4750-1-git-send-email-chenhc@lemote.com>
	<601437ae-2860-c48a-aa7c-4da37aeb6256@arm.com>
	<20170918155134.GC16672@infradead.org>
In-Reply-To: <20170918155134.GC16672@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?Q2hyaXN0b3BoIEhlbGx3aWc=?= <hch@infradead.org>, =?utf-8?B?Um9iaW4gTXVycGh5?= <robin.murphy@arm.com>
Cc: =?utf-8?B?QW5kcmV3IE1vcnRvbg==?= <akpm@linux-foundation.org>, =?utf-8?B?RnV4aW4gWmhhbmc=?= <zhangfx@lemote.com>, =?utf-8?B?bGludXgtbW0=?= <linux-mm@kvack.org>, =?utf-8?B?bGludXgta2VybmVs?= <linux-kernel@vger.kernel.org>, =?utf-8?B?c3RhYmxl?= <stable@vger.kernel.org>

T2gsIEkga25vdywgSSd2ZSBtYWtlIGEgbWlzdGFrZSwgZG1hcG9vbCBkb2Vzbid0IG5lZWQg
dG8gY2hhbmdlLg0KDQpIdWFjYWkNCiANCiANCi0tLS0tLS0tLS0tLS0tLS0tLSBPcmlnaW5h
bCAtLS0tLS0tLS0tLS0tLS0tLS0NCkZyb206ICAiQ2hyaXN0b3BoIEhlbGx3aWciPGhjaEBp
bmZyYWRlYWQub3JnPjsNCkRhdGU6ICBNb24sIFNlcCAxOCwgMjAxNyAxMTo1MSBQTQ0KVG86
ICAiUm9iaW4gTXVycGh5Ijxyb2Jpbi5tdXJwaHlAYXJtLmNvbT47IA0KQ2M6ICAiSHVhY2Fp
IENoZW4iPGNoZW5oY0BsZW1vdGUuY29tPjsgIkFuZHJldyBNb3J0b24iPGFrcG1AbGludXgt
Zm91bmRhdGlvbi5vcmc+OyAiRnV4aW4gWmhhbmciPHpoYW5nZnhAbGVtb3RlLmNvbT47ICJs
aW51eC1tbSI8bGludXgtbW1Aa3ZhY2sub3JnPjsgImxpbnV4LWtlcm5lbCI8bGludXgta2Vy
bmVsQHZnZXIua2VybmVsLm9yZz47ICJzdGFibGUiPHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmc+
OyANClN1YmplY3Q6ICBSZTogW1Y1LCAyLzNdIG1tOiBkbWFwb29sOiBBbGlnbiB0byBBUkNI
X0RNQV9NSU5BTElHTiBpbm5vbi1jb2hlcmVudCBETUEgbW9kZQ0KDQogDQpPbiBNb24sIFNl
cCAxOCwgMjAxNyBhdCAxMDo0NDo1NEFNICswMTAwLCBSb2JpbiBNdXJwaHkgd3JvdGU6DQo+
IE9uIDE4LzA5LzE3IDA1OjIyLCBIdWFjYWkgQ2hlbiB3cm90ZToNCj4gPiBJbiBub24tY29o
ZXJlbnQgRE1BIG1vZGUsIGtlcm5lbCB1c2VzIGNhY2hlIGZsdXNoaW5nIG9wZXJhdGlvbnMg
dG8NCj4gPiBtYWludGFpbiBJL08gY29oZXJlbmN5LCBzbyB0aGUgZG1hcG9vbCBvYmplY3Rz
IHNob3VsZCBiZSBhbGlnbmVkIHRvDQo+ID4gQVJDSF9ETUFfTUlOQUxJR04uIE90aGVyd2lz
ZSwgaXQgd2lsbCBjYXVzZSBkYXRhIGNvcnJ1cHRpb24sIGF0IGxlYXN0DQo+ID4gb24gTUlQ
UzoNCj4gPiANCj4gPiAJU3RlcCAxLCBkbWFfbWFwX3NpbmdsZQ0KPiA+IAlTdGVwIDIsIGNh
Y2hlX2ludmFsaWRhdGUgKG5vIHdyaXRlYmFjaykNCj4gPiAJU3RlcCAzLCBkbWFfZnJvbV9k
ZXZpY2UNCj4gPiAJU3RlcCA0LCBkbWFfdW5tYXBfc2luZ2xlDQo+IA0KPiBUaGlzIGlzIGEg
bWFzc2l2ZSByZWQgd2FybmluZyBmbGFnIGZvciB0aGUgd2hvbGUgc2VyaWVzLCBiZWNhdXNl
IERNQQ0KPiBwb29scyBkb24ndCB3b3JrIGxpa2UgdGhhdC4gQXQgYmVzdCwgdGhpcyB3aWxs
IGRvIG5vdGhpbmcsIGFuZCBhdCB3b3JzdA0KPiBpdCBpcyBwYXBlcmluZyBvdmVyIGVncmVn
aW91cyBidWdzIGVsc2V3aGVyZS4gU3RyZWFtaW5nIG1hcHBpbmdzIG9mDQo+IGNvaGVyZW50
IGFsbG9jYXRpb25zIG1lYW5zIGNvbXBsZXRlbHkgYnJva2VuIGNvZGUuDQoNCk9oLCBJIGhh
ZG4ndCBldmVuIHNlZW4gdGhhdCBwYXJ0LiAgWWVzLCBkbWEgY29oZXJlbnQgKGFuZCBwb29s
KQ0KYWxsb2NhdGlvbnMgbXVzdCBuZXZlciBiZSB1c2VkIGZvciBzdHJlYW1pbmcgbWFwcGlu
Z3MuICBJIHdpc2ggd2UnZA0KaGF2ZSBzb21lIGRlYnVnIGluZnJhc3RydWN0dXJlIHRvIHdh
cm4gb24gc3VjaCB1c2VzLg==



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
