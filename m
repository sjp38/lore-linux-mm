Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD476B0005
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 08:08:39 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t5-v6so2668829pgp.17
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 05:08:39 -0700 (PDT)
Received: from smtp.jd.com (smtp.jd.com. [58.83.206.59])
        by mx.google.com with ESMTPS id b16-v6si5522402pgw.478.2018.08.09.05.08.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Aug 2018 05:08:37 -0700 (PDT)
From: =?utf-8?B?5YiY56GV54S2?= <liushuoran@jd.com>
Subject: Re: FUSE: write operations trigger balance_dirty_pages when using
 writeback cache
Date: Thu, 9 Aug 2018 12:08:32 +0000
Message-ID: <EA52CBCF76D5E04D95BED55B83577BE7A677C0@MBX50.360buyAD.local>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, =?utf-8?B?5YiY5rW36ZSL?= <bjliuhaifeng@jd.com>, =?utf-8?B?6YOt5Y2r6b6Z?= <guoweilong@jd.com>

VGhhbmtzIGZvciB0aGUgYWR2aWNlLiBJIHRyaWVkIHJlbW92aW5nIEJESV9DQVBfU1RSSUNUTElN
SVQsIGFuZCBpdCB3b3Jrcy4gVGhlcmUgaXMgbm8gYmFsYW5jZV9kaXJ0eV9wYWdlcygpIHRyaWdn
ZXJlZCwgYW5kIHRoZSBwZXJmb3JtYW5jZSBpbXByb3ZlcyBhIGxvdC4NCg0KVGVzdGVkIGJ5IGxp
YmZ1c2UgcGFzc3Rocm91Z2hfbGwgZXhhbXBsZSBhbmQgZmlvOg0KLi9wYXNzdGhyb3VnaF9sbCAt
byB3cml0ZWJhY2sgL21udC9mdXNlLw0KZmlvIC0tbmFtZT10ZXN0IC0taW9lbmdpbmU9cHN5bmMg
LS1kaXJlY3Rvcnk9L21udC9mdXNlL2hvbWUvdGVzdCAtLWJzPTRrIC0tZGlyZWN0PTAgLS1zaXpl
PTY0TSAtLXJ3PXdyaXRlIC0tZmFsbG9jYXRlPTAgLS1udW1qb2JzPTENCg0KcGVyZm9ybWFuY2Ug
d2l0aCBCRElfQ0FQX1NUUklDVExJTUlUOg0KV1JJVEU6IGJ3PTE1OE1pQi9zICgxNjVNQi9zKSwg
MTU4TWlCL3MtMTU4TWlCL3MgKDE2NU1CL3MtMTY1TUIvcyksIGlvPTY0LjBNaUIgKDY3LjFNQiks
IHJ1bj00MDYtNDA2bXNlYw0KDQpQZXJmb3JtYW5jZSB3aXRob3V0IEJESV9DQVBfU1RSSUNUTElN
SVQ6DQpXUklURTogYnc9MTU2MU1pQi9zICgxNjM3TUIvcyksIDE1NjFNaUIvcy0xNTYxTWlCL3Mg
KDE2MzdNQi9zLTE2MzdNQi9zKSwgaW89NjQuME1pQiAoNjcuMU1CKSwgcnVuPTQxLTQxbXNlYw0K
DQpIb3dldmVyLCBJIHdvbmRlciBpZiB0aGVyZSBhcmUgc29tZSBzaWRlLWVmZmVjdHMgdG8gcmVt
b3ZlIGl0PyBTaW5jZSBpdCBzZWVtcyB0aGF0IHRoZSBvcmlnaW5hbCBwdXJwb3NlIG9mIHRoaXMg
ZmVhdHVyZSBpcyB0byBwcmV2ZW50IEZVU0UgZnJvbSBjb25zdW1pbmcgdG9vIG11Y2ggbWVtb3J5
LiBQbGVhc2UgY29ycmVjdCBtZSBpZiBJIGFtIG1pc3Rha2VuLiBUaGFua3MgaW4gYWR2YW5jZS4N
Cg0KDQpSZWdhcmRzLA0KU2h1b3Jhbg0KDQoNCi0tLS0t6YKu5Lu25Y6f5Lu2LS0tLS0NCuWPkeS7
tuS6ujogTWlrbG9zIFN6ZXJlZGkgW21haWx0bzptaWtsb3NAc3plcmVkaS5odV0gDQrlj5HpgIHm
l7bpl7Q6IDIwMTjlubQ45pyIOeaXpSAxNjozMA0K5pS25Lu25Lq6OiDliJjnoZXnhLYgPGxpdXNo
dW9yYW5AamQuY29tPg0K5oqE6YCBOiBsaW51eC1mc2RldmVsQHZnZXIua2VybmVsLm9yZzsgbGlu
dXgta2VybmVsQHZnZXIua2VybmVsLm9yZw0K5Li76aKYOiBSZTogRlVTRTogd3JpdGUgb3BlcmF0
aW9ucyB0cmlnZ2VyIGJhbGFuY2VfZGlydHlfcGFnZXMgd2hlbiB1c2luZyB3cml0ZWJhY2sgY2Fj
aGUNCg0KT24gVGh1LCBBdWcgOSwgMjAxOCBhdCA5OjMxIEFNLCDliJjnoZXnhLYgPGxpdXNodW9y
YW5AamQuY29tPiB3cm90ZToNCj4gVGhhbmsgeW91IGZvciB0aGUgcHJvbXB0IHJlcGx5Lg0KPg0K
PiBJIHRyaWVkIHRoaXMgY29uZmlnLCBidXQgc3RpbGwgY2FuIGdldCBiYWxhbmNlX2RpcnR5X3Bh
Z2VzIHRyaWdnZXJlZC4NCg0KSSB0aGluayBpdCBtYXkgYmUgZHVlIHRvIEJESV9DQVBfU1RSSUNU
TElNSVQgdXNlZCBieSBmdXNlLiAgSWYgeW91IHJlbW92ZSB0aGF0IHNldHRpbmcgZnJvbSBmdXNl
IGluIHRoZSBrZXJuZWwgeW91IHNob3VsZCBub3QgYmUgZ2V0dGluZyB0aGUgYmFsYW5jZV9kaXJ0
eV9wYWdlcygpIGFzIG9mdGVuLg0KDQpOb3Qgc3VyZSBpZiB0aGF0J3MgdGhlIHJlYWxwcm9ibGVt
LCB0aG91Z2gsIHRoYXQgZGVwZW5kcyBvbiBob3cgbXVjaCB0aW1lIGlzIHNwZW50IGluIGJhbGFu
Y2VfZGlydHlfcGFnZXMoKS4gIFlvdSBjYW4gdHJ5IHByb2ZpbGluZyB0aGUga2VybmVsIHRvIGZp
bmQgdGhhdCBvdXQuDQoNCk15IGd1ZXNzIGlzIHRoYXQgdGhlIHJlYWwgY2F1c2Ugb2YgdGhlIHNs
b3dkb3duIGlzIHNvbWUgb3RoZXIgcGxhY2UuDQpUaGVyZSdzIGZvciBleGFtcGxlIGEga25vd24g
aXNzdWUgd2l0aCBzZWxpbnV4IHJlbGF0ZWQgZ2V0eGF0dHIgdGhyYXNoaW5nLiAgRGlzYWJsaW5n
IGdldHhhdHRyIG9uIHlvdXIgZmlsZXN5c3RlbSBtYXkgc2lnbmlmaWNhbnRseSBpbXByb3ZlIHBl
cmZvcm1hbmNlLg0KDQpUaGFua3MsDQpNaWtsb3MNCg==
