Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id CC7B76B007B
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:29:56 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id b13so3408401wgh.0
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:29:56 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id fl4si1426366wib.99.2014.10.22.04.29.55
        for <linux-mm@kvack.org>;
        Wed, 22 Oct 2014 04:29:55 -0700 (PDT)
Date: Wed, 22 Oct 2014 14:29:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
Message-ID: <20141022112925.GH30588@node.dhcp.inet.fi>
References: <20141020215633.717315139@infradead.org>
 <1413963289.26628.3.camel@linux-t7sj.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413963289.26628.3.camel@linux-t7sj.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 22, 2014 at 12:34:49AM -0700, Davidlohr Bueso wrote:
> On Mon, 2014-10-20 at 23:56 +0200, Peter Zijlstra wrote:
> > Hi,
> > 
> > I figured I'd give my 2010 speculative fault series another spin:
> > 
> >   https://lkml.org/lkml/2010/1/4/257
> > 
> > Since then I think many of the outstanding issues have changed sufficiently to
> > warrant another go. In particular Al Viro's delayed fput seems to have made it
> > entirely 'normal' to delay fput(). Lai Jiangshan's SRCU rewrite provided us
> > with call_srcu() and my preemptible mmu_gather removed the TLB flushes from
> > under the PTL.
> > 
> > The code needs way more attention but builds a kernel and runs the
> > micro-benchmark so I figured I'd post it before sinking more time into it.
> > 
> > I realize the micro-bench is about as good as it gets for this series and not
> > very realistic otherwise, but I think it does show the potential benefit the
> > approach has.
> > 
> > (patches go against .18-rc1+)
> 
> I think patch 2/6 is borken:
> 
> error: patch failed: mm/memory.c:2025
> error: mm/memory.c: patch does not apply
> 
> and related, as you mention, I would very much welcome having the
> introduction of 'struct faut_env' as a separate cleanup patch. May I
> suggest renaming it to fault_cxt?

What about extend start using 'struct vm_fault' earlier by stack?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
