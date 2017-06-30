Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D93CC6B0279
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 02:59:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b11so5781427wmh.0
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 23:59:31 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id i49si5616131wra.51.2017.06.29.23.59.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 23:59:30 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id y5so6205224wmh.3
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 23:59:30 -0700 (PDT)
Date: Fri, 30 Jun 2017 08:59:26 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/5] Last bits for initial 5-level paging enabling
Message-ID: <20170630065926.fcwax3odtla4dp4t@gmail.com>
References: <20170622122608.80435-1-kirill.shutemov@linux.intel.com>
 <20170623090601.njsmucxdy4rev6zw@gmail.com>
 <20170623144915.4d6esghvicnczuaj@black.fi.intel.com>
 <20170629150657.urgapbzmf3jy6jgp@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170629150657.urgapbzmf3jy6jgp@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> > > Can I apply them in this order cleanly, without breaking bisection:
> > > 
> > > >   x86/mm: Rename tasksize_32bit/64bit to task_size_32bit/64bit
> > > >   x86/mpx: Do not allow MPX if we have mappings above 47-bit
> > > >   x86/mm: Prepare to expose larger address space to userspace
> > > >   x86/mm: Allow userspace have mapping above 47-bit
> > > >   x86: Enable 5-level paging support
> > > 
> > > ?
> > > 
> > > I.e. I'd like to move the first patch last.
> > > 
> > > The reason is that we should first get all quirks and assumptions fixed, all 
> > > facilities implemented - and only then enable 5-level paging as a final step which 
> > > produces a well working kernel.
> > > 
> > > (This should also make it slightly easier to analyze any potential regressions in 
> > > earlier patches.)
> > 
> > Just checked bisectability with this order on allmodconfig -- works fine.
> 
> Ingo, if there's no objections, can we get these applied?

Just this week, which is the final week of the development window, we had two 
fixes for the 5-level pagetables commits, so we need to delay the rest to right 
after -rc1.

Could you please resend them them (and any followup patches), in the suggested 
order? I don't see any conceptual problems, so this is only about timing and 
maximizing stability.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
