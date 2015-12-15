Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9176B0254
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 12:53:34 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id n128so8429769pfn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 09:53:34 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 69si3089209pfc.197.2015.12.15.09.53.33
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 09:53:33 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Date: Tue, 15 Dec 2015 17:53:31 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F8566E@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com>
	<23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
	<20151215131135.GE25973@pd.tnic>
 <CAPcyv4gMr6LcZqjxt6fAoEiaa0AzcgMxnp2+V=TWJ1eHb6nC3A@mail.gmail.com>
In-Reply-To: <CAPcyv4gMr6LcZqjxt6fAoEiaa0AzcgMxnp2+V=TWJ1eHb6nC3A@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

Pj4gLi4uIGFuZCB0aGUgbm9uLXRlbXBvcmFsIHZlcnNpb24gaXMgdGhlIG9wdGltYWwgb25lIGV2
ZW4gdGhvdWdoIHdlJ3JlDQo+PiBkZWZhdWx0aW5nIHRvIGNvcHlfdXNlcl9lbmhhbmNlZF9mYXN0
X3N0cmluZyBmb3IgbWVtY3B5IG9uIG1vZGVybiBJbnRlbA0KPj4gQ1BVcy4uLj8NCg0KTXkgY3Vy
cmVudCBnZW5lcmF0aW9uIGNwdSBoYXMgYSBiaXQgb2YgYW4gaXNzdWUgd2l0aCByZWNvdmVyaW5n
IGZyb20gYQ0KbWFjaGluZSBjaGVjayBpbiBhICJyZXAgbW92IiAuLi4gc28gSSdtIHdvcmtpbmcg
d2l0aCBhIHZlcnNpb24gb2YgbWVtY3B5DQp0aGF0IHVucm9sbHMgaW50byBpbmRpdmlkdWFsIG1v
diBpbnN0cnVjdGlvbnMgZm9yIG5vdy4NCg0KPiBBdCBsZWFzdCB0aGUgcG1lbSBkcml2ZXIgdXNl
IGNhc2UgZG9lcyBub3Qgd2FudCBjYWNoaW5nIG9mIHRoZQ0KPiBzb3VyY2UtYnVmZmVyIHNpbmNl
IHRoYXQgaXMgdGhlIHJhdyAiZGlzayIgbWVkaWEuICBJLmUuIGluDQo+IHBtZW1fZG9fYnZlYygp
IHdlJ2QgdXNlIHRoaXMgdG8gaW1wbGVtZW50IG1lbWNweV9mcm9tX3BtZW0oKS4NCj4gSG93ZXZl
ciwgY2FjaGluZyB0aGUgZGVzdGluYXRpb24tYnVmZmVyIG1heSBwcm92ZSBiZW5lZmljaWFsIHNp
bmNlDQo+IHRoYXQgZGF0YSBpcyBsaWtlbHkgdG8gYmUgY29uc3VtZWQgaW1tZWRpYXRlbHkgYnkg
dGhlIHRocmVhZCB0aGF0DQo+IHN1Ym1pdHRlZCB0aGUgaS9vLg0KDQpJIGNhbiBkcm9wIHRoZSAi
bnRpIiBmcm9tIHRoZSBkZXN0aW5hdGlvbiBtb3Zlcy4gIERvZXMgIm50aSIgd29yaw0Kb24gdGhl
IGxvYWQgZnJvbSBzb3VyY2UgYWRkcmVzcyBzaWRlIHRvIGF2b2lkIGNhY2hlIGFsbG9jYXRpb24/
DQoNCk9uIGFub3RoZXIgdG9waWMgcmFpc2VkIGJ5IEJvcmlzIC4uLiBpcyB0aGVyZSBzb21lIENP
TkZJR19QTUVNKg0KdGhhdCBJIHNob3VsZCB1c2UgYXMgYSBkZXBlbmRlbmN5IHRvIGVuYWJsZSBh
bGwgdGhpcz8NCg0KLVRvbnkNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
