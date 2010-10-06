Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AC3D66B0087
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 10:53:52 -0400 (EDT)
Date: Wed, 6 Oct 2010 11:20:50 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH v6 03/12] Retry fault before vmentry
Message-ID: <20101006142050.GA31423@amt.cnet>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-4-git-send-email-gleb@redhat.com>
 <20101005155409.GB28955@amt.cnet>
 <20101006110704.GW11145@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101006110704.GW11145@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 06, 2010 at 01:07:04PM +0200, Gleb Natapov wrote:
> > Can't you set a bit in vcpu->requests instead, and handle it in "out:"
> > at the end of vcpu_enter_guest? 
> > 
> > To have a single entry point for pagefaults, after vmexit handling.
> Jumping to "out:" will skip vmexit handling anyway, so we will not reuse
> same call site anyway. I don't see yet why the way you propose will have
> an advantage.

What i meant was to call pagefault handler after vmexit handling.

Because the way it is in your patch now, with pre pagefault on entry,
one has to make an effort to verify ordering wrt other events on entry
processing.

With pre pagefault after vmexit, its more natural.

Does that make sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
