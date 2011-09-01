Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CE6A56B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 17:18:31 -0400 (EDT)
Date: Thu, 1 Sep 2011 14:17:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Revert] Re: [PATCH] mm: sync vmalloc address space page tables
 in alloc_vm_area()
Message-Id: <20110901141754.76cef93b.akpm@linux-foundation.org>
In-Reply-To: <4E5FED1A.1000300@goop.org>
References: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com>
	<20110901161134.GA8979@dumpdata.com>
	<4E5FED1A.1000300@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, David Vrabel <david.vrabel@citrix.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "namhyung@gmail.com" <namhyung@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On Thu, 01 Sep 2011 13:37:46 -0700
Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> On 09/01/2011 09:11 AM, Konrad Rzeszutek Wilk wrote:
> > On Thu, Sep 01, 2011 at 12:51:03PM +0100, David Vrabel wrote:
> >> From: David Vrabel <david.vrabel@citrix.com>
> > Andrew,
> >
> > I was wondering if you would be Ok with this patch for 3.1.
> >
> > It is a revert (I can prepare a proper revert if you would like
> > that instead of this patch).

David's patch looks better than a straight reversion.

Problem is, I can't find David's original email anywhere.  Someone's
been playing games with To: headers?

> > The users of this particular function (alloc_vm_area) are just
> > Xen. There are no others.
> 
> I'd prefer to put explicit vmalloc_sync_all()s in the callsites where
> necessary,

What would that patch look like?  Bear in mind that we'll need something
suitable for 3.1 and for a 3.0 backport.

> and ultimately try to work out ways of avoiding it altogether
> (like have some hypercall wrapper which touches the arg memory to make
> sure its mapped?).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
