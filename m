Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 828E76B0032
	for <linux-mm@kvack.org>; Sun, 21 Jun 2015 16:23:05 -0400 (EDT)
Received: by wicgi11 with SMTP id gi11so58148660wic.0
        for <linux-mm@kvack.org>; Sun, 21 Jun 2015 13:23:04 -0700 (PDT)
Received: from johanna1.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id wl7si31361811wjc.206.2015.06.21.13.23.03
        for <linux-mm@kvack.org>;
        Sun, 21 Jun 2015 13:23:03 -0700 (PDT)
Date: Sun, 21 Jun 2015 23:22:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150621202231.GB6766@node.dhcp.inet.fi>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <5577078B.2000503@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5577078B.2000503@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Jun 09, 2015 at 08:34:35AM -0700, Dave Hansen wrote:
> On 06/09/2015 05:43 AM, Ingo Molnar wrote:
> > +static char tlb_flush_target[PAGE_SIZE] __aligned(4096);
> > +static void fn_flush_tlb_one(void)
> > +{
> > +	unsigned long addr = (unsigned long)&tlb_flush_target;
> > +
> > +	tlb_flush_target[0]++;
> > +	__flush_tlb_one(addr);
> > +}
> 
> So we've got an increment of a variable in kernel memory (which is
> almost surely in the L1), then we flush that memory location, and repeat
> the increment.

BTW, Ingo, have you disabled direct mapping of kernel memory with 2M/1G
pages for the test? 

I'm just thinking if there is chance that the test shooting out 1G tlb
entry. In this case we're measure wrong thing.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
