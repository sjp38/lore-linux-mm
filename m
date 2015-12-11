Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 673156B0257
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 16:19:19 -0500 (EST)
Received: by pabur14 with SMTP id ur14so71242176pab.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 13:19:19 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rq5si3430051pab.160.2015.12.11.13.19.18
        for <linux-mm@kvack.org>;
        Fri, 11 Dec 2015 13:19:18 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Date: Fri, 11 Dec 2015 21:19:17 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com>
 <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com>
In-Reply-To: <CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew
 Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

PiBJIHN0aWxsIGRvbid0IGdldCB0aGUgQklUKDYzKSB0aGluZy4gIENhbiB5b3UgZXhwbGFpbiBp
dD8NCg0KSXQgd2lsbCBiZSBtb3JlIG9idmlvdXMgd2hlbiBJIGdldCBhcm91bmQgdG8gd3JpdGlu
ZyBjb3B5X2Zyb21fdXNlcigpLg0KDQpUaGVuIHdlIHdpbGwgaGF2ZSBhIGZ1bmN0aW9uIHRoYXQg
Y2FuIHRha2UgcGFnZSBmYXVsdHMgaWYgdGhlcmUgYXJlIHBhZ2VzDQp0aGF0IGFyZSBub3QgcHJl
c2VudC4gIElmIHRoZSBwYWdlIGZhdWx0cyBjYW4ndCBiZSBmaXhlZCB3ZSBoYXZlIGEgLUVGQVVM
VA0KY29uZGl0aW9uLiBXZSBjYW4gYWxzbyB0YWtlIG1hY2hpbmUgY2hlY2tzIGlmIHdlIHJlYWRz
IGZyb20gYSBsb2NhdGlvbiB3aXRoIGFuDQp1bmNvcnJlY3RlZCBlcnJvci4NCg0KV2UgbmVlZCB0
byBkaXN0aW5ndWlzaCB0aGVzZSB0d28gY2FzZXMgYmVjYXVzZSB0aGUgYWN0aW9uIHdlIHRha2Ug
aXMNCmRpZmZlcmVudC4gRm9yIHRoZSB1bnJlc29sdmVkIHBhZ2UgZmF1bHQgd2UgYWxyZWFkeSBo
YXZlIHRoZSBBQkkgdGhhdCB0aGUNCmNvcHlfdG8vZnJvbV91c2VyKCkgZnVuY3Rpb25zIHJldHVy
biB6ZXJvIGZvciBzdWNjZXNzLCBhbmQgYSBub24temVybw0KcmV0dXJuIGlzIHRoZSBudW1iZXIg
b2Ygbm90LWNvcGllZCBieXRlcy4NCg0KU28gZm9yIG15IG5ldyBjYXNlIEknbSBzZXR0aW5nIGJp
dDYzIC4uLiB0aGlzIGlzIG5ldmVyIGdvaW5nIHRvIGJlIHNldCBmb3INCmEgZmFpbGVkIHBhZ2Ug
ZmF1bHQuDQoNCmNvcHlfZnJvbV91c2VyKCkgY29uY2VwdHVhbGx5IHdpbGwgbG9vayBsaWtlIHRo
aXM6DQoNCmludCBjb3B5X2Zyb21fdXNlcih2b2lkICp0bywgdm9pZCAqZnJvbSwgdW5zaWduZWQg
bG9uZyBuKQ0Kew0KCXU2NCByZXQgPSBtY3NhZmVfbWVtY3B5KHRvLCBmcm9tLCBuKTsNCg0KCWlm
IChDT1BZX0hBRF9NQ0hFQ0socikpIHsNCgkJaWYgKG1lbW9yeV9mYWlsdXJlKENPUFlfTUNIRUNL
X1BBRERSKHJldCkgPj4gUEFHRV9TSVpFLCAuLi4pKQ0KCQkJZm9yY2Vfc2lnKFNJR0JVUywgY3Vy
cmVudCk7DQoJCXJldHVybiBzb21ldGhpbmc7DQoJfSBlbHNlDQoJCXJldHVybiByZXQ7DQp9DQoN
Ci1Ub255DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
