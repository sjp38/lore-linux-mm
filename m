Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD406B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 17:35:19 -0500 (EST)
Received: by pfee188 with SMTP id e188so2316165pfe.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:35:19 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 68si3786931pfi.137.2015.12.11.14.35.18
        for <linux-mm@kvack.org>;
        Fri, 11 Dec 2015 14:35:18 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Date: Fri, 11 Dec 2015 22:35:17 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F82F97@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com>
 <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
 <CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82EEF@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4hR+FNZ7b1duZ9g9e0xWnAwBsMtnzms_ZRvssXNJUaVoA@mail.gmail.com>
 <CALCETrVcj=4sDaEXGNtYuq0kXLm7K9de1catqWPi25ae56g8Jg@mail.gmail.com>
In-Reply-To: <CALCETrVcj=4sDaEXGNtYuq0kXLm7K9de1catqWPi25ae56g8Jg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, "Williams, Dan J" <dan.j.williams@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew
 Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

PiBBbHNvLCBhcmUgdGhlcmUgcmVhbGx5IFBDT01NSVQtY2FwYWJsZSBDUFVzIHRoYXQgc3RpbGwg
Zm9yY2libHkNCj4gYnJvYWRjYXN0IE1DRT8gIElmLCBzbywgdGhhdCdzIHVuZm9ydHVuYXRlLg0K
DQpQQ09NTUlUIGFuZCBMTUNFIGFycml2ZSB0b2dldGhlciAuLi4gdGhvdWdoIEJJT1MgaXMgaW4g
dGhlIGRlY2lzaW9uDQpwYXRoIHRvIGVuYWJsZSBMTUNFLCBzbyBpdCBpcyBwb3NzaWJsZSB0aGF0
IHNvbWUgc3lzdGVtcyBjb3VsZCBzdGlsbA0KYnJvYWRjYXN0IGlmIHRoZSBCSU9TIHdyaXRlciBk
ZWNpZGVzIHRvIG5vdCBhbGxvdyBsb2NhbC4NCg0KQnV0IGEgbWFjaGluZSBjaGVjayBzYWZlIGNv
cHlfZnJvbV91c2VyKCkgd291bGQgYmUgdXNlZnVsDQpjdXJyZW50IGdlbmVyYXRpb24gY3B1cyB0
aGF0IGJyb2FkY2FzdCBhbGwgdGhlIHRpbWUuDQoNCi1Ub255DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
