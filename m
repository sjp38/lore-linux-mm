Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 48C006B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 18:36:39 -0500 (EST)
Date: Tue, 8 Nov 2011 15:36:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Xen-devel] Re: [Revert] Re: [PATCH] mm: sync vmalloc address
 space page tables in alloc_vm_area()
Message-Id: <20111108153635.45b3c517.akpm@linux-foundation.org>
In-Reply-To: <20111108233132.GA1230@phenom.dumpdata.com>
References: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com>
	<20110901161134.GA8979@dumpdata.com>
	<4E5FED1A.1000300@goop.org>
	<20110901141754.76cef93b.akpm@linux-foundation.org>
	<4E60C067.4010600@citrix.com>
	<20110902153204.59a928c1.akpm@linux-foundation.org>
	<20110906163553.GA28971@dumpdata.com>
	<20111105133846.GA4415@phenom.dumpdata.com>
	<20111107203613.GA6546@phenom.dumpdata.com>
	<20111108150153.e3229374.akpm@linux-foundation.org>
	<20111108233132.GA1230@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "namhyung@gmail.com" <namhyung@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Vrabel <david.vrabel@citrix.com>, "rientjes@google.com" <rientjes@google.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On Tue, 8 Nov 2011 18:31:32 -0500
Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:

> > > And Linus picked it up.
> > 
> > I've no idea what's going on here.
> 
> Heh. Sorry for being so confusing. Merge windows are a bit stressful and
> I sometimes end up writing run-on sentences.
> > 
> > > .. snip..
> > > > 
> > > > Also, not sure what you thought of this patch below?
> > > 
> > > Patch included as attachment for easier review..
> > 
> > The patch "xen: map foreign pages for shared rings by updating the PTEs
> > directly" (whcih looks harnless enough) is not present in 3.2-rc1 or linux-next.
> 
> <nods>. That is b/c it does not have your Ack. The patch applies cleanly to
> 3.2-rc1 (as all the other patches that it depends on are now in 3.2-rc1).
> 
> I am humbly asking for you to:
>  a) review the patch (which you did) and get an idea whether you are OK (sounds like you are)

Yup.

>  b) pick it up in your -mm tree.

No added benefit there.

> or alternately:
>  b) give an Ack on the patch so I can put it in my linux-next and push it
>     for 3.2-rc1.

That's OK by me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
