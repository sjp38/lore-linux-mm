Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D7C006B016A
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 03:31:26 -0400 (EDT)
Received: by wyi11 with SMTP id 11so2655390wyi.14
        for <linux-mm@kvack.org>; Fri, 02 Sep 2011 00:31:22 -0700 (PDT)
Date: Fri, 02 Sep 2011 08:31:16 +0100
Subject: Re: [Xen-devel] Re: [Revert] Re: [PATCH] mm: sync vmalloc address
 space page tables in alloc_vm_area()
From: Keir Fraser <keir.xen@gmail.com>
Message-ID: <CA8644D4.20348%keir.xen@gmail.com>
In-Reply-To: <1314948154.28989.158.camel@zakaz.uk.xensource.com>
Mime-version: 1.0
Content-type: text/plain;
	charset="US-ASCII"
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <Ian.Campbell@citrix.com>, Jeremy Fitzhardinge <jeremy@goop.org>
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "namhyung@gmail.com" <namhyung@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Vrabel <david.vrabel@citrix.com>, "rientjes@google.com" <rientjes@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On 02/09/2011 08:22, "Ian Campbell" <Ian.Campbell@citrix.com> wrote:

> On Thu, 2011-09-01 at 21:37 +0100, Jeremy Fitzhardinge wrote:
>> On 09/01/2011 09:11 AM, Konrad Rzeszutek Wilk wrote:
>>> On Thu, Sep 01, 2011 at 12:51:03PM +0100, David Vrabel wrote:
>>>> From: David Vrabel <david.vrabel@citrix.com>
>>> Andrew,
>>> 
>>> I was wondering if you would be Ok with this patch for 3.1.
>>> 
>>> It is a revert (I can prepare a proper revert if you would like
>>> that instead of this patch).
>>> 
>>> The users of this particular function (alloc_vm_area) are just
>>> Xen. There are no others.
>> 
>> I'd prefer to put explicit vmalloc_sync_all()s in the callsites where
>> necessary, and ultimately try to work out ways of avoiding it altogether
>> (like have some hypercall wrapper which touches the arg memory to make
>> sure its mapped?).
> 
> That only syncs the current pagetable though. If that is sufficient (and
> it could well be) then perhaps just doing a vmalloc_sync_one on the
> current page tables directly would be better than faulting to do it?

It's probably sufficient unless the kernel has non-voluntary preemption, and
we are not preempt_disable()d.

 -- Keir

> It's the sort of thing you could hide inside the gnttab_set_map_op type
> helpers I guess?
> 
> Ian.
> 
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xensource.com
> http://lists.xensource.com/xen-devel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
