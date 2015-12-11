Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE2C6B0254
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 17:45:35 -0500 (EST)
Received: by pfee188 with SMTP id e188so2426505pfe.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:45:35 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ie7si3839185pad.155.2015.12.11.14.45.34
        for <linux-mm@kvack.org>;
        Fri, 11 Dec 2015 14:45:35 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Date: Fri, 11 Dec 2015 22:45:33 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F82FED@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com>
 <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
 <CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82EEF@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4hR+FNZ7b1duZ9g9e0xWnAwBsMtnzms_ZRvssXNJUaVoA@mail.gmail.com>
 <CALCETrVcj=4sDaEXGNtYuq0kXLm7K9de1catqWPi25ae56g8Jg@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82F97@ORSMSX114.amr.corp.intel.com>
 <CALCETrUK1raRagO=JxCRpy0_eKfS56gce737fVe9rtJqNwH+_A@mail.gmail.com>
In-Reply-To: <CALCETrUK1raRagO=JxCRpy0_eKfS56gce737fVe9rtJqNwH+_A@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

Pj4gQnV0IGEgbWFjaGluZSBjaGVjayBzYWZlIGNvcHlfZnJvbV91c2VyKCkgd291bGQgYmUgdXNl
ZnVsDQo+PiBjdXJyZW50IGdlbmVyYXRpb24gY3B1cyB0aGF0IGJyb2FkY2FzdCBhbGwgdGhlIHRp
bWUuDQo+DQo+IEZhaXIgZW5vdWdoLg0KDQpUaGFua3MgZm9yIHNwZW5kaW5nIHRoZSB0aW1lIHRv
IGxvb2sgYXQgdGhpcy4gIENvYXhpbmcgbWUgdG8gcmUtd3JpdGUgdGhlDQp0YWlsIG9mIGRvX21h
Y2hpbmVfY2hlY2soKSBoYXMgbWFkZSB0aGF0IGNvZGUgbXVjaCBiZXR0ZXIuIFRvbyBtYW55DQp5
ZWFycyBvZiBvbmUgcGF0Y2ggb24gdG9wIG9mIGFub3RoZXIgd2l0aG91dCBsb29raW5nIGF0IHRo
ZSB3aG9sZSBjb250ZXh0Lg0KDQpDb2dpdGF0ZSBvbiB0aGlzIHNlcmllcyBvdmVyIHRoZSB3ZWVr
ZW5kIGFuZCBzZWUgaWYgeW91IGNhbiBnaXZlIG1lDQphbiBBY2tlZC1ieSBvciBSZXZpZXdlZC1i
eSAoSSdsbCBiZSBhZGRpbmcgYSAjZGVmaW5lIGZvciBCSVQoNjMpKS4NCg0KLVRvbnkNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
