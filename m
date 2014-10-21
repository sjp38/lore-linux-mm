Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 842896B0074
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 13:12:52 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id y10so1864129wgg.3
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 10:12:52 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id s7si13468173wix.49.2014.10.21.10.12.47
        for <linux-mm@kvack.org>;
        Tue, 21 Oct 2014 10:12:48 -0700 (PDT)
Date: Tue, 21 Oct 2014 20:09:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
Message-ID: <20141021170948.GA25964@node.dhcp.inet.fi>
References: <20141020215633.717315139@infradead.org>
 <20141021162340.GA5508@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141021162340.GA5508@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 21, 2014 at 06:23:40PM +0200, Ingo Molnar wrote:
> 
> * Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > My Ivy Bridge EP (2*10*2) has a ~58% improvement in pagefault throughput:
> > 
> > PRE:
> >        149,441,555      page-faults                  ( +-  1.25% )
> >
> > POST:
> >        236,442,626      page-faults                  ( +-  0.08% )
> 
> > My Ivy Bridge EX (4*15*2) has a ~78% improvement in pagefault throughput:
> > 
> > PRE:
> >        105,789,078      page-faults                 ( +-  2.24% )
> >
> > POST:
> >        187,751,767      page-faults                 ( +-  2.24% )
> 
> I guess the 'PRE' and 'POST' numbers should be flipped around?

I think it's faults per second.

It would be interesting to see if the patchset affects non-condended case.
Like a one-threaded workload.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
