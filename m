Received: from smtp3.akamai.com (vwall2.sanmateo.corp.akamai.com [172.23.1.72])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j530ZXRt002746
	for <linux-mm@kvack.org>; Thu, 2 Jun 2005 17:35:34 -0700 (PDT)
Message-ID: <429FA5D4.87FD9B6C@akamai.com>
Date: Thu, 02 Jun 2005 17:35:32 -0700
From: Prasanna Meda <pmeda@akamai.com>
MIME-Version: 1.0
Subject: Re: [patch] scm: fix scm_fp_list allocation problem
References: <200506012227.PAA05624@allur.sanmateo.akamai.com> <20050602161341.3d94f17b.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>
>
> I figure a 32k kmalloc will support an OPEN_MAX of 4095 on 64-bit 4k
> pagesize machines.
>
> Just how high do you want to go?
>

At least 16k, and up to 64k fds.

>
> Given that you need to patch the kernel to support larger SCM_MAX_FD, why
> not add this patch at the same time, keep it out of the main tree?

Can do.
Ideally every fd openable should be passed over. I work towards that goal
and submit again.


>
> > +{
> > +     struct scm_fp_list *fpl;
> > +     int size  = sizeof(struct scm_fp_list);
> > +
> > +     if (size <= PAGE_SIZE) {
> > +             fpl = (struct scm_fp_list *) kmalloc (size, GFP_KERNEL);
> > +     }
> > +     else {
> > +             fpl = (struct scm_fp_list *) vmalloc (size);
> > +     }
>
> - Unneeded braces
>
> - Unneeded typecast
>
> - Unneeded space
>
> - Incorrect `else' indenting.
>
> Should be:
>
>         if (size <= PAGE_SIZE)
>                 fpl = kmalloc(size, GFP_KERNEL);
>         else
>                 fpl = vmalloc(size);

Taken all suggestions.


Thanks,
Prasanna.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
