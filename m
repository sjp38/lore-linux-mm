Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AEC8B6B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 16:37:54 -0400 (EDT)
Message-ID: <4E5FED1A.1000300@goop.org>
Date: Thu, 01 Sep 2011 13:37:46 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [Revert] Re: [PATCH] mm: sync vmalloc address space page tables
 in alloc_vm_area()
References: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com> <20110901161134.GA8979@dumpdata.com>
In-Reply-To: <20110901161134.GA8979@dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "namhyung@gmail.com" <namhyung@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On 09/01/2011 09:11 AM, Konrad Rzeszutek Wilk wrote:
> On Thu, Sep 01, 2011 at 12:51:03PM +0100, David Vrabel wrote:
>> From: David Vrabel <david.vrabel@citrix.com>
> Andrew,
>
> I was wondering if you would be Ok with this patch for 3.1.
>
> It is a revert (I can prepare a proper revert if you would like
> that instead of this patch).
>
> The users of this particular function (alloc_vm_area) are just
> Xen. There are no others.

I'd prefer to put explicit vmalloc_sync_all()s in the callsites where
necessary, and ultimately try to work out ways of avoiding it altogether
(like have some hypercall wrapper which touches the arg memory to make
sure its mapped?).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
