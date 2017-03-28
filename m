Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7F076B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 05:39:50 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q19so1481919wra.6
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:39:50 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id m3si4079028wrb.16.2017.03.28.02.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 02:39:49 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id w43so18037072wrb.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:39:49 -0700 (PDT)
Date: Tue, 28 Mar 2017 11:39:46 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 6/8] x86/dump_pagetables: Add support 5-level paging
Message-ID: <20170328093946.GA30567@gmail.com>
References: <20170327162925.16092-1-kirill.shutemov@linux.intel.com>
 <20170327162925.16092-7-kirill.shutemov@linux.intel.com>
 <20170328061259.GC20135@gmail.com>
 <20170328093040.wayhvqxijreps2mq@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328093040.wayhvqxijreps2mq@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Tue, Mar 28, 2017 at 08:12:59AM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > +#if PTRS_PER_P4D > 1
> > > +
> > > +static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
> > > +							unsigned long P)
> > 
> > Pretty ugly line break. Either don't break the line, or break it in a more logical 
> > place, like:
> > 
> > static void
> > walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr, unsigned long P)
> > 
> > > +	start = (p4d_t *) pgd_page_vaddr(addr);
> > 
> > The space between the type cast and the function invocation is not needed.
> 
> Both style issues you have pointed to are inherited from handling of other
> page table levels.
> 
> Do you want me to adjust them too?

Yes, pre-existing uncleanlinesses are not a reason to replicate them going 
forward. Feel free to do it in a separate preparatory patch if the noise
is too large.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
