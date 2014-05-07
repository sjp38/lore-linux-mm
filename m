Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 77CCB6B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 12:45:11 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so1420378pab.1
        for <linux-mm@kvack.org>; Wed, 07 May 2014 09:45:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id vw5si14148756pab.5.2014.05.07.09.45.10
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 09:45:10 -0700 (PDT)
Date: Wed, 7 May 2014 09:46:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC, PATCH 0/8] remap_file_pages() decommission
Message-Id: <20140507094601.0f7fd266.akpm@linux-foundation.org>
In-Reply-To: <20140507091258.GP11096@twins.programming.kicks-ass.net>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20140506143542.1d4e5f41be58b3ad3543ffe3@linux-foundation.org>
	<CA+55aFwUO5ubckFFEF+R=yos-Qd3Br4Fy3-LpXL0bDWCmMhb6g@mail.gmail.com>
	<20140506230323.GA14821@node.dhcp.inet.fi>
	<20140506162856.2a94db336b91db5525ed0457@linux-foundation.org>
	<20140507091258.GP11096@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>

On Wed, 7 May 2014 11:12:58 +0200 Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, May 06, 2014 at 04:28:56PM -0700, Andrew Morton wrote:
> > On Wed, 7 May 2014 02:03:23 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > 
> > > remap_file_pages(2) was invented to be able efficiently map parts of
> > > huge file into limited 32-bit virtual address space such as in database
> > > workloads.
> > > 
> > > Nonlinear mappings are pain to support and it seems there's no
> > > legitimate use-cases nowadays since 64-bit systems are widely available.
> > > 
> > > Let's deprecate remap_file_pages() syscall in hope to get rid of code
> > > one day.
> > 
> > Before we do this we should ensure that your proposed replacement is viable
> > and desirable.  If we later decide not to proceed with it, this patch will
> > sow confusion.
> 
> Chicken meet Egg ?
> 
> How are we supposed to test if its viable if we have no known users?

Same way we always do - finish the code, developer test, review, give
it a spin in linux-next, etc.  Do some microbenchmarking to get an
understanding of the impact on people who are using r_f_p for real. 
The current patchset looks rather alphaish.

> The
> printk() might maybe (hopefully) get us some reaction in say a years
> time, much longer if we're really unlucky.
> 
> That said, we could make the syscall return -ENOSYS unless a sysctl was
> touched. The printk() would indeed have to mention said sysctl and a
> place to find information about why we're doing this..
> 
> But by creating more pain (people have to actually set the sysctl, and
> we'll have to universally agree to inflict pain on distro people that
> set it by default -- say, starve them from beer at the next conf.) we're
> more likely to get an answer sooner.

Could be.  We should consult distro people, Oracle people...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
