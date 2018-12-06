Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89C2A6B7A87
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:59:12 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g7so403589plp.10
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:59:12 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id x15si416845pgq.378.2018.12.06.06.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 06:59:11 -0800 (PST)
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
References: <cover.1543903910.git.alison.schofield@intel.com>
 <20181204092550.GT11614@hirez.programming.kicks-ass.net>
 <20181204094647.tjsvwjgp3zq6yqce@black.fi.intel.com>
 <063026c66b599ba4ff0b30a5ecc7d2c716e4da5b.camel@intel.com>
 <20181206112255.4bbumbrf5nnz4t2z@kshutemo-mobl1>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a0a1e0d2-ef32-8378-5363-b730afc99c03@intel.com>
Date: Thu, 6 Dec 2018 06:59:10 -0800
MIME-Version: 1.0
In-Reply-To: <20181206112255.4bbumbrf5nnz4t2z@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, "Schofield, Alison" <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On 12/6/18 3:22 AM, Kirill A. Shutemov wrote:
>> When you say "disable encryption to a page" does the encryption get
>> actually disabled or does the CPU just decrypt it transparently i.e.
>> what happens physically?
> Yes, it gets disabled. Physically. It overrides TME encryption.

I know MKTME itself has a runtime overhead and we expect it to have a
performance impact in the low single digits.  Does TME have that
overhead?  Presumably MKTME plus no-encryption is not expected to have
the overhead.

We should probably mention that in the changelogs too.
