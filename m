Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 140AF8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 06:54:37 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g7so2530801plp.10
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 03:54:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v28sor5389966pfk.14.2018.12.07.03.54.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 03:54:36 -0800 (PST)
Date: Fri, 7 Dec 2018 14:54:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Message-ID: <20181207115430.xrj64q4j7hqdmbsw@kshutemo-mobl1>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <20181204092550.GT11614@hirez.programming.kicks-ass.net>
 <20181204094647.tjsvwjgp3zq6yqce@black.fi.intel.com>
 <063026c66b599ba4ff0b30a5ecc7d2c716e4da5b.camel@intel.com>
 <20181206112255.4bbumbrf5nnz4t2z@kshutemo-mobl1>
 <3a0a11bc557288190f6fa804dc8e7825738ccc70.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a0a11bc557288190f6fa804dc8e7825738ccc70.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On Thu, Dec 06, 2018 at 09:23:20PM +0000, Sakkinen, Jarkko wrote:
> On Thu, 2018-12-06 at 14:22 +0300, Kirill A. Shutemov wrote:
> > When you say "disable encryption to a page" does the encryption get
> > > actually disabled or does the CPU just decrypt it transparently i.e.
> > > what happens physically?
> > 
> > Yes, it gets disabled. Physically. It overrides TME encryption.
> 
> OK, thanks for confirmation. BTW, how much is the penalty to keep it
> always enabled? Is it something that would not make sense for some
> other reasons?

We don't have any numbers to share at this point.

-- 
 Kirill A. Shutemov
