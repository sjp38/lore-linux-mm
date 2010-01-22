Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 229B6600783
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 02:25:27 -0500 (EST)
Date: Fri, 22 Jan 2010 09:25:10 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
Message-ID: <20100122072510.GD2076@redhat.com>
References: <20100118085022.GA30698@redhat.com>
 <4B5510B1.9010202@zytor.com>
 <20100119065537.GF14345@redhat.com>
 <4B55E5D8.1070402@zytor.com>
 <20100119174438.GA19450@redhat.com>
 <4B5611A9.4050301@zytor.com>
 <20100120100254.GC5238@redhat.com>
 <4B5740CD.4020005@zytor.com>
 <4B58181B.60405@redhat.com>
 <4B58770A.3050107@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B58770A.3050107@zytor.com>
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Avi Kivity <avi@redhat.com>, Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 07:47:22AM -0800, H. Peter Anvin wrote:
> On 01/21/2010 01:02 AM, Avi Kivity wrote:
> >>
> >> You can also just emulate the state transition -- since you know
> >> you're dealing with a flat protected-mode or long-mode OS (and just
> >> make that a condition of enabling the feature) you don't have to deal
> >> with all the strange combinations of directions that an unrestricted
> >> x86 event can take.  Since it's an exception, it is unconditional.
> > 
> > Do you mean create the stack frame manually?  I'd really like to avoid
> > that for many reasons, one of which is performance (need to do all the
> > virt-to-phys walks manually), the other is that we're certain to end up
> > with something horribly underspecified.  I'd really like to keep as
> > close as possible to the hardware.  For the alternative approach, see Xen.
> > 
> 
> I obviously didn't mean to do something which didn't look like a
> hardware-delivered exception.  That by itself provides a tight spec.
> The performance issue is real, of course.
> 
> Obviously, the design of VT-x was before my time at Intel, so I'm not
> familiar with why the tradeoffs that were done they way they were.
> 
Is it so out of question to reserver exception below 32 for PV use?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
