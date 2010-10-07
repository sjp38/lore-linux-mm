Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 051EB6B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 12:03:57 -0400 (EDT)
Received: by bwz10 with SMTP id 10so6593bwz.14
        for <linux-mm@kvack.org>; Thu, 07 Oct 2010 09:03:54 -0700 (PDT)
Date: Thu, 7 Oct 2010 18:03:41 +0200
From: Gleb Natapov <gleb@minantech.com>
Subject: Re: [PATCH v6 04/12] Add memory slot versioning and use it to
 provide fast guest write interface
Message-ID: <20101007160340.GD4120@minantech.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-5-git-send-email-gleb@redhat.com>
 <20101005165738.GA32750@amt.cnet>
 <20101006111417.GX11145@redhat.com>
 <20101006143847.GB31423@amt.cnet>
 <20101006200836.GC4120@minantech.com>
 <4CAD9A2D.7020009@redhat.com>
 <20101007154248.GA30949@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101007154248.GA30949@amt.cnet>
Sender: owner-linux-mm@kvack.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 12:42:48PM -0300, Marcelo Tosatti wrote:
> On Thu, Oct 07, 2010 at 12:00:13PM +0200, Avi Kivity wrote:
> >  On 10/06/2010 10:08 PM, Gleb Natapov wrote:
> > >>  Malicious userspace can cause entry to be cached, ioctl
> > >>  SET_USER_MEMORY_REGION 2^32 times, generation number will match,
> > >>  mark_page_dirty_in_slot will be called with pointer to freed memory.
> > >>
> > >Hmm. To zap all cached entires on overflow we need to track them. If we
> > >will track then we can zap them on each slot update and drop "generation"
> > >entirely.
> > 
> > To track them you need locking.
> > 
> > Isn't SET_USER_MEMORY_REGION so slow that calling it 2^32 times
> > isn't really feasible?
> 
> Assuming it takes 1ms, it would take 49 days.
> 
We may fail ioctl when max value is reached. The question is how much slot
changes can we expect from real guest during its lifetime.

> > In any case, can use u64 generation count.
> 
> Agree.
Yes, 64 bit ought to be enough for anybody.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
