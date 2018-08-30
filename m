Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EDF236B53B1
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 18:36:36 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id w19-v6so8911563ioa.10
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:36:36 -0700 (PDT)
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730116.outbound.protection.outlook.com. [40.107.73.116])
        by mx.google.com with ESMTPS id t7-v6si5676932iof.220.2018.08.30.15.36.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 15:36:36 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v1 5/5] mm/memory_hotplug: print only with DEBUG_VM in
 online/offline_pages()
Date: Thu, 30 Aug 2018 22:36:33 +0000
Message-ID: <1c503734-e662-a775-609e-1a9862dedd50@microsoft.com>
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-6-david@redhat.com>
 <7892e949-6c2c-9659-a595-177037d0e203@redhat.com>
In-Reply-To: <7892e949-6c2c-9659-a595-177037d0e203@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <0B54AEF0D4F11840BFFC7E8A5EEC8C1E@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

DQoNCk9uIDgvMjAvMTggNjo0NiBBTSwgRGF2aWQgSGlsZGVuYnJhbmQgd3JvdGU6DQo+IE9uIDE2
LjA4LjIwMTggMTI6MDYsIERhdmlkIEhpbGRlbmJyYW5kIHdyb3RlOg0KPj4gTGV0J3MgdHJ5IHRv
IG1pbmltemUgdGhlIG5vaXNlLg0KPj4NCj4+IFNpZ25lZC1vZmYtYnk6IERhdmlkIEhpbGRlbmJy
YW5kIDxkYXZpZEByZWRoYXQuY29tPg0KPj4gLS0tDQo+PiAgbW0vbWVtb3J5X2hvdHBsdWcuYyB8
IDYgKysrKysrDQo+PiAgMSBmaWxlIGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygrKQ0KPj4NCj4+IGRp
ZmYgLS1naXQgYS9tbS9tZW1vcnlfaG90cGx1Zy5jIGIvbW0vbWVtb3J5X2hvdHBsdWcuYw0KPj4g
aW5kZXggYmJiZDE2ZjlkODc3Li42ZmVjMmRjNmE3M2QgMTAwNjQ0DQo+PiAtLS0gYS9tbS9tZW1v
cnlfaG90cGx1Zy5jDQo+PiArKysgYi9tbS9tZW1vcnlfaG90cGx1Zy5jDQo+PiBAQCAtOTY2LDkg
Kzk2NiwxMSBAQCBpbnQgX19yZWYgb25saW5lX3BhZ2VzKHVuc2lnbmVkIGxvbmcgcGZuLCB1bnNp
Z25lZCBsb25nIG5yX3BhZ2VzLCBpbnQgb25saW5lX3R5cA0KPj4gIAlyZXR1cm4gMDsNCj4+ICAN
Cj4+ICBmYWlsZWRfYWRkaXRpb246DQo+PiArI2lmZGVmIENPTkZJR19ERUJVR19WTQ0KPj4gIAlw
cl9kZWJ1Zygib25saW5lX3BhZ2VzIFttZW0gJSMwMTBsbHgtJSMwMTBsbHhdIGZhaWxlZFxuIiwN
Cj4+ICAJCSAodW5zaWduZWQgbG9uZyBsb25nKSBwZm4gPDwgUEFHRV9TSElGVCwNCj4+ICAJCSAo
KCh1bnNpZ25lZCBsb25nIGxvbmcpIHBmbiArIG5yX3BhZ2VzKSA8PCBQQUdFX1NISUZUKSAtIDEp
Ow0KPj4gKyNlbmRpZg0KPj4gIAltZW1vcnlfbm90aWZ5KE1FTV9DQU5DRUxfT05MSU5FLCAmYXJn
KTsNCj4+ICAJcmV0dXJuIHJldDsNCj4+ICB9DQo+PiBAQCAtMTY2MCw3ICsxNjYyLDkgQEAgaW50
IG9mZmxpbmVfcGFnZXModW5zaWduZWQgbG9uZyBzdGFydF9wZm4sIHVuc2lnbmVkIGxvbmcgbnJf
cGFnZXMpDQo+PiAgCW9mZmxpbmVkX3BhZ2VzID0gY2hlY2tfcGFnZXNfaXNvbGF0ZWQoc3RhcnRf
cGZuLCBlbmRfcGZuKTsNCj4+ICAJaWYgKG9mZmxpbmVkX3BhZ2VzIDwgMCkNCj4+ICAJCWdvdG8g
cmVwZWF0Ow0KPj4gKyNpZmRlZiBDT05GSUdfREVCVUdfVk0NCj4+ICAJcHJfaW5mbygiT2ZmbGlu
ZWQgUGFnZXMgJWxkXG4iLCBvZmZsaW5lZF9wYWdlcyk7DQo+PiArI2VuZGlmDQo+PiAgCS8qIE9r
LCBhbGwgb2Ygb3VyIHRhcmdldCBpcyBpc29sYXRlZC4NCj4+ICAJICAgV2UgY2Fubm90IGRvIHJv
bGxiYWNrIGF0IHRoaXMgcG9pbnQuICovDQo+PiAgCW9mZmxpbmVfaXNvbGF0ZWRfcGFnZXMoc3Rh
cnRfcGZuLCBlbmRfcGZuKTsNCj4+IEBAIC0xNjk1LDkgKzE2OTksMTEgQEAgaW50IG9mZmxpbmVf
cGFnZXModW5zaWduZWQgbG9uZyBzdGFydF9wZm4sIHVuc2lnbmVkIGxvbmcgbnJfcGFnZXMpDQo+
PiAgCXJldHVybiAwOw0KPj4gIA0KPj4gIGZhaWxlZF9yZW1vdmFsOg0KPj4gKyNpZmRlZiBDT05G
SUdfREVCVUdfVk0NCj4+ICAJcHJfZGVidWcoIm1lbW9yeSBvZmZsaW5pbmcgW21lbSAlIzAxMGxs
eC0lIzAxMGxseF0gZmFpbGVkXG4iLA0KPj4gIAkJICh1bnNpZ25lZCBsb25nIGxvbmcpIHN0YXJ0
X3BmbiA8PCBQQUdFX1NISUZULA0KPj4gIAkJICgodW5zaWduZWQgbG9uZyBsb25nKSBlbmRfcGZu
IDw8IFBBR0VfU0hJRlQpIC0gMSk7DQo+PiArI2VuZGlmDQo+PiAgCW1lbW9yeV9ub3RpZnkoTUVN
X0NBTkNFTF9PRkZMSU5FLCAmYXJnKTsNCj4+ICAJLyogcHVzaGJhY2sgdG8gZnJlZSBhcmVhICov
DQo+PiAgCXVuZG9faXNvbGF0ZV9wYWdlX3JhbmdlKHN0YXJ0X3BmbiwgZW5kX3BmbiwgTUlHUkFU
RV9NT1ZBQkxFKTsNCj4+DQo+IA0KPiBJJ2xsIGRyb3AgdGhpcyBwYXRjaCBmb3Igbm93LCBtYXli
ZSB0aGUgZXJyb3IgbWVzc2FnZXMgYXJlIGFjdHVhbGx5DQo+IHVzZWZ1bCB3aGVuIGRlYnVnZ2lu
ZyBhIGNyYXNoZHVtcCBvZiBhIHN5c3RlbSB3aXRob3V0IENPTkZJR19ERUJVR19WTS4NCj4gDQoN
ClllcywgcGxlYXNlIGRyb3AgaXQsIG5vIHJlYXNvbiB0byByZWR1Y2UgYW1vdW50IG9mIHRoZXNl
IG1lc3NhZ2VzLiBUaGV5DQphcmUgdXNlZnVsLg0KDQpUaGFuayB5b3UsDQpQYXZlbA==
