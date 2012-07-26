Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 995F36B004D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 01:21:32 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2954670pbb.14
        for <linux-mm@kvack.org>; Wed, 25 Jul 2012 22:21:31 -0700 (PDT)
Date: Thu, 26 Jul 2012 13:22:40 +0800
From: majianpeng <majianpeng@gmail.com>
Subject: Re: Re: [RFC] block_dev:Fix bug when read/write block-device which is larger than 16TB in 32bit-OS.
References: <201205291656322966937@gmail.com> <201207242044249532601@gmail.com>,
	<20120724134838.GA26102@infradead.org>
Mime-Version: 1.0
Message-ID: <201207261322369377080@gmail.com>
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, viro <viro@ZenIV.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

T24gMjAxMi0wNy0yNCAyMTo0OCBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGluZnJhZGVhZC5vcmc+
IFdyb3RlOg0KPk9uIFR1ZSwgSnVsIDI0LCAyMDEyIGF0IDA4OjQ0OjI3UE0gKzA4MDAsIG1hamlh
bnBlbmcgd3JvdGU6DQo+PiBPbiAyMDEyLTA1LTI5IDE2OjU2IG1hamlhbnBlbmcgPG1hamlhbnBl
bmdAZ21haWwuY29tPiBXcm90ZToNCj4+ID5UaGUgc2l6ZSBvZiBibG9jay1kZXZpY2UgaXMgbGFy
Z2VyIHRoYW4gMTZUQiwgYW5kIHRoZSBvcyBpcyAzMmJpdC4NCj4+ID5JZiB0aGUgb2Zmc2V0IG9m
IHJlYWQvd3JpdGUgaXMgbGFyZ2VyIHRoZW4gMTZUQi4gVGhlIGluZGV4IG9mIGFkZHJlc3Nfc3Bh
Y2Ugd2lsbA0KPj4gPm92ZXJmbG93IGFuZCBzdXBwbHkgZGF0YSBmcm9tIGxvdyBvZmZzZXQgaW5z
dGVhZC4NCj4NCj5XZSBjYW4ndCBzdXBwb3J0ID4gMTZUQiBibG9jayBkZXZpY2Ugb24gMzItYml0
IHN5c3RlbXMgd2l0aCA0ayBwYWdlDQo+c2l6ZSwganVzdCBsaWtlIHdlIGNhbid0IHN1cHBvcnQg
ZmlsZXMgdGhhdCBsYXJnZS4NCj4NCj5Gb3IgZmlsZXN5c3RlbXMgdGhlIHNfbWF4Ynl0ZXMgbGlt
aXQgb2YgTUFYX0xGU19GSUxFU0laRSB0YWtlcyBjYXJlIG9mDQo+dGhhdCwgYnV0IGl0IHNlZW1z
IGxpa2Ugd2UgbWlzcyB0aGF0IGNoZWNrIGZvciBibG9jayBkZXZpY2VzLg0KPg0KPlRoZSBwcm9w
ZXIgZml4IGlzIHRvIGFkZCB0aGF0IGNoZWNrIChlaXRoZXIgdmlhIHNfbWF4Ynl0ZXMgb3IgYnkN
Cj5jaGVja2luZyBNQVhfTEZTX0ZJTEVTSVpFKSB0byBnZW5lcmljX3dyaXRlX2NoZWNrcyBhbmQN
Cj5nZW5lcmljX2ZpbGVfYWlvX3JlYWQgKG9yIGEgYmxvY2sgZGV2aWNlIHNwZWNpZmljIHdyYXBw
ZXIpDQo+DQpJIGhhZCBhIHByb2JsZW06d2h5IGRvIHJlYWQtb3BlcmF0aW9uICBub3QgdG8gY2hl
Y2sgbGlrZSBnZW5lcmljX3dyaXRlX2NoZWtjcz8=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
