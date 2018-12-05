Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0F06B72A9
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:27:47 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id o23so14211740pll.0
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:27:47 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u11si22561877plm.8.2018.12.04.21.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 21:27:46 -0800 (PST)
Date: Tue, 4 Dec 2018 21:30:20 -0800
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC v2 09/13] mm: Restrict memory encryption to anonymous VMA's
Message-ID: <20181205053020.GB18596@alison-desk.jf.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <0b294e74f06a0d6bee51efcd7b0eb1f20b00babe.1543903910.git.alison.schofield@intel.com>
 <20181204091044.GP11614@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204091044.GP11614@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Dec 04, 2018 at 10:10:44AM +0100, Peter Zijlstra wrote:
> > + * Encrypted mprotect is only supported on anonymous mappings.
> > + * All VMA's in the requested range must be anonymous. If this
> > + * test fails on any single VMA, the entire mprotect request fails.
> > + */
> > +bool mem_supports_encryption(struct vm_area_struct *vma, unsigned long end)
> 
> That's a 'weird' interface and cannot do what the comment says it should
> do.

More please? With MKTME, only anonymous memory supports encryption.
Is it the naming that's weird, or you don't see it doing what it says?

> > +	struct vm_area_struct *test_vma = vma;
> 
> That variable is utterly pointless.
Got it. Will fix.

Thanks
