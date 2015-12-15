Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id E506B6B025B
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 18:46:05 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id e66so1858442pfe.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 15:46:05 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 86si806614pfs.88.2015.12.15.15.46.05
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 15:46:05 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCHV2 2/3] x86, ras: Extend machine check recovery code to
 annotated ring0 areas
Date: Tue, 15 Dec 2015 23:46:03 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F85DBE@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com>
 <e8029c58c7d4b5094ec274c78dee01d390317d4d.1449861203.git.tony.luck@intel.com>
 <20151215114314.GD25973@pd.tnic>
In-Reply-To: <20151215114314.GD25973@pd.tnic>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "x86@kernel.org" <x86@kernel.org>

Pj4gKwkvKiBGYXVsdCB3YXMgaW4gcmVjb3ZlcmFibGUgYXJlYSBvZiB0aGUga2VybmVsICovDQo+
PiArCWlmICgobS5jcyAmIDMpICE9IDMgJiYgd29yc3QgPT0gTUNFX0FSX1NFVkVSSVRZKQ0KPj4g
KwkJaWYgKCFmaXh1cF9tY2V4Y2VwdGlvbihyZWdzLCBtLmFkZHIpKQ0KPj4gKwkJCW1jZV9wYW5p
YygiRmFpbGVkIGtlcm5lbCBtb2RlIHJlY292ZXJ5IiwgJm0sIE5VTEwpOw0KPgkJCQkgICBeXl5e
Xl5eXl5eXl5eXl5eXl5eXl5eXl5eXl4NCj4NCj4gRG9lcyB0aGF0IGFsd2F5cyBpbXBseSBhIGZh
aWxlZCBrZXJuZWwgbW9kZSByZWNvdmVyeT8gSSBkb24ndCBzZWUNCj4NCj4JKG0uY3MgPT0gMCBh
bmQgTUNFX0FSX1NFVkVSSVRZKQ0KPg0KPiBNQ0VzIGFsd2F5cyBtZWFuaW5nIHRoYXQgYSByZWNv
dmVyeSBzaG91bGQgYmUgYXR0ZW1wdGVkIHRoZXJlLiBJIHRoaW5rDQo+IHRoaXMgc2hvdWxkIHNp
bXBseSBzYXkNCj4NCj4JbWNlX3BhbmljKCJGYXRhbCBtYWNoaW5lIGNoZWNrIG9uIGN1cnJlbnQg
Q1BVIiwgJm0sIG1zZyk7DQoNCkkgZG9uJ3QgdGhpbmsgdGhpcyBjYW4gZXZlciBoYXBwZW4uIElm
IHdlIHdlcmUgaW4ga2VybmVsIG1vZGUgYW5kIGRlY2lkZWQNCnRoYXQgdGhlIHNldmVyaXR5IHdh
cyBBUl9TRVZFUklUWSAuLi4gdGhlbiBzZWFyY2hfbWNleGNlcHRpb25fdGFibGUoKQ0KZm91bmQg
YW4gZW50cnkgZm9yIHRoZSBJUCB3aGVyZSB0aGUgbWFjaGluZSBjaGVjayBoYXBwZW5lZC4NCg0K
VGhlIG9ubHkgd2F5IGZvciBmaXh1cF9leGNlcHRpb24gdG8gZmFpbCBpcyBpZiBzZWFyY2hfbWNl
eGNlcHRpb25fdGFibGUoKQ0Kbm93IHN1ZGRlbmx5IGRvZXNuJ3QgZmluZCB0aGUgZW50cnkgaXQg
Zm91bmQgZWFybGllci4NCg0KQnV0IGlmIHRoaXMgImNhbid0IGhhcHBlbiIgdGhpbmcgYWN0dWFs
bHkgZG9lcyBoYXBwZW4gLi4uIEknZCBsaWtlIHRoZSBwYW5pYw0KbWVzc2FnZSB0byBiZSBkaWZm
ZXJlbnQgZnJvbSBvdGhlciBtY2VfcGFuaWMoKSBzbyB5b3UnbGwga25vdyB0byBibGFtZQ0KbWUu
DQoNCkFwcGxpZWQgYWxsIHRoZSBvdGhlciBzdWdnZXN0aW9ucy4NCg0KLVRvbnkNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
