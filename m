Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E92536B006C
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 18:01:55 -0500 (EST)
Date: Tue, 8 Nov 2011 15:01:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Xen-devel] Re: [Revert] Re: [PATCH] mm: sync vmalloc address
 space page tables in alloc_vm_area()
Message-Id: <20111108150153.e3229374.akpm@linux-foundation.org>
In-Reply-To: <20111107203613.GA6546@phenom.dumpdata.com>
References: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com>
	<20110901161134.GA8979@dumpdata.com>
	<4E5FED1A.1000300@goop.org>
	<20110901141754.76cef93b.akpm@linux-foundation.org>
	<4E60C067.4010600@citrix.com>
	<20110902153204.59a928c1.akpm@linux-foundation.org>
	<20110906163553.GA28971@dumpdata.com>
	<20111105133846.GA4415@phenom.dumpdata.com>
	<20111107203613.GA6546@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>, Jeremy Fitzhardinge <jeremy@goop.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "namhyung@gmail.com" <namhyung@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "rientjes@google.com" <rientjes@google.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On Mon, 7 Nov 2011 15:36:13 -0500
Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:

> > > > 
> > > > oookay, I queued this for 3.1 and tagged it for a 3.0.x backport.  I
> > > > *think* that's the outcome of this discussion, for the short-term?
> > > 
> > > <nods> Yup. Thanks!
> > 
> > Hey Andrew,
> > 
> > The long term outcome is the patchset that David worked on. I've sent
> > a GIT PULL to Linus to pick up the Xen related patches that switch over
> > the users of the right API:
> > 
> >  (xen) stable/vmalloc-3.2 for Linux 3.2-rc0
> > 
> > (https://lkml.org/lkml/2011/10/29/82)
> 
> And Linus picked it up.

I've no idea what's going on here.

> .. snip..
> > 
> > Also, not sure what you thought of this patch below?
> 
> Patch included as attachment for easier review..

The patch "xen: map foreign pages for shared rings by updating the PTEs
directly" (whcih looks harnless enough) is not present in 3.2-rc1 or linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
