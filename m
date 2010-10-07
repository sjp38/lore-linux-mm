Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A9B666B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 11:57:49 -0400 (EDT)
Date: Thu, 7 Oct 2010 12:42:48 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH v6 04/12] Add memory slot versioning and use it to
 provide fast guest write interface
Message-ID: <20101007154248.GA30949@amt.cnet>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-5-git-send-email-gleb@redhat.com>
 <20101005165738.GA32750@amt.cnet>
 <20101006111417.GX11145@redhat.com>
 <20101006143847.GB31423@amt.cnet>
 <20101006200836.GC4120@minantech.com>
 <4CAD9A2D.7020009@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CAD9A2D.7020009@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Gleb Natapov <gleb@minantech.com>, Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 12:00:13PM +0200, Avi Kivity wrote:
>  On 10/06/2010 10:08 PM, Gleb Natapov wrote:
> >>  Malicious userspace can cause entry to be cached, ioctl
> >>  SET_USER_MEMORY_REGION 2^32 times, generation number will match,
> >>  mark_page_dirty_in_slot will be called with pointer to freed memory.
> >>
> >Hmm. To zap all cached entires on overflow we need to track them. If we
> >will track then we can zap them on each slot update and drop "generation"
> >entirely.
> 
> To track them you need locking.
> 
> Isn't SET_USER_MEMORY_REGION so slow that calling it 2^32 times
> isn't really feasible?

Assuming it takes 1ms, it would take 49 days.

> In any case, can use u64 generation count.

Agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
