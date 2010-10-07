Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AB27F6B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 14:45:06 -0400 (EDT)
Date: Thu, 7 Oct 2010 20:44:57 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6 03/12] Retry fault before vmentry
Message-ID: <20101007184457.GA8354@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-4-git-send-email-gleb@redhat.com>
 <20101005155409.GB28955@amt.cnet>
 <20101006110704.GW11145@redhat.com>
 <20101006142050.GA31423@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101006142050.GA31423@amt.cnet>
Sender: owner-linux-mm@kvack.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 06, 2010 at 11:20:50AM -0300, Marcelo Tosatti wrote:
> On Wed, Oct 06, 2010 at 01:07:04PM +0200, Gleb Natapov wrote:
> > > Can't you set a bit in vcpu->requests instead, and handle it in "out:"
> > > at the end of vcpu_enter_guest? 
> > > 
> > > To have a single entry point for pagefaults, after vmexit handling.
> > Jumping to "out:" will skip vmexit handling anyway, so we will not reuse
> > same call site anyway. I don't see yet why the way you propose will have
> > an advantage.
> 
> What i meant was to call pagefault handler after vmexit handling.
> 
> Because the way it is in your patch now, with pre pagefault on entry,
> one has to make an effort to verify ordering wrt other events on entry
> processing.
> 
What events do you have in mind?

> With pre pagefault after vmexit, its more natural.
> 
I do not see non-ugly way to pass information that is needed to perform
the prefault to the place you want me to put it. We can skip guest entry
in case prefault was done which will have the same effect as your
proposal, but I want to have a good reason to do so since otherwise we
will just do more work for nothing on guest entry.

> Does that make sense?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
