Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 62E556B0085
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 13:23:30 -0400 (EDT)
Date: Thu, 7 Oct 2010 19:23:18 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6 04/12] Add memory slot versioning and use it to
 provide fast guest write interface
Message-ID: <20101007172318.GC2397@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-5-git-send-email-gleb@redhat.com>
 <20101005165738.GA32750@amt.cnet>
 <20101006111417.GX11145@redhat.com>
 <20101006143847.GB31423@amt.cnet>
 <20101006200836.GC4120@minantech.com>
 <4CAD9A2D.7020009@redhat.com>
 <20101007154248.GA30949@amt.cnet>
 <20101007160340.GD4120@minantech.com>
 <4CADF365.3080406@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CADF365.3080406@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Gleb Natapov <gleb@minantech.com>, Marcelo Tosatti <mtosatti@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 06:20:53PM +0200, Avi Kivity wrote:
>  On 10/07/2010 06:03 PM, Gleb Natapov wrote:
> >>  >
> >>  >  Isn't SET_USER_MEMORY_REGION so slow that calling it 2^32 times
> >>  >  isn't really feasible?
> >>
> >>  Assuming it takes 1ms, it would take 49 days.
> >>
> >We may fail ioctl when max value is reached. The question is how much slot
> >changes can we expect from real guest during its lifetime.
> >
> 
> A normal guest has a 30 Hz timer for reading the vga framebuffer,
> multiple slots.  Let's assume 100 Hz frequency, that gives 490 days
> until things stop working.
> 
And reading vga framebuffer needs slots changes because of dirty map
tracking?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
