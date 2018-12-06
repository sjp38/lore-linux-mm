Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECAA6B79AB
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 06:23:02 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a10so43346plp.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 03:23:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v191sor135209pgb.53.2018.12.06.03.23.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 03:23:00 -0800 (PST)
Date: Thu, 6 Dec 2018 14:22:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Message-ID: <20181206112255.4bbumbrf5nnz4t2z@kshutemo-mobl1>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <20181204092550.GT11614@hirez.programming.kicks-ass.net>
 <20181204094647.tjsvwjgp3zq6yqce@black.fi.intel.com>
 <063026c66b599ba4ff0b30a5ecc7d2c716e4da5b.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <063026c66b599ba4ff0b30a5ecc7d2c716e4da5b.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On Wed, Dec 05, 2018 at 08:32:52PM +0000, Sakkinen, Jarkko wrote:
> On Tue, 2018-12-04 at 12:46 +0300, Kirill A. Shutemov wrote:
> > On Tue, Dec 04, 2018 at 09:25:50AM +0000, Peter Zijlstra wrote:
> > > On Mon, Dec 03, 2018 at 11:39:47PM -0800, Alison Schofield wrote:
> > > > (Multi-Key Total Memory Encryption)
> > > 
> > > I think that MKTME is a horrible name, and doesn't appear to accurately
> > > describe what it does either. Specifically the 'total' seems out of
> > > place, it doesn't require all memory to be encrypted.
> > 
> > MKTME implies TME. TME is enabled by BIOS and it encrypts all memory with
> > CPU-generated key. MKTME allows to use other keys or disable encryption
> > for a page.
> 
> When you say "disable encryption to a page" does the encryption get
> actually disabled or does the CPU just decrypt it transparently i.e.
> what happens physically?

Yes, it gets disabled. Physically. It overrides TME encryption.

-- 
 Kirill A. Shutemov
