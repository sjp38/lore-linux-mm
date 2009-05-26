Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A4F876B0062
	for <linux-mm@kvack.org>; Tue, 26 May 2009 17:05:51 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9CA7E82C429
	for <linux-mm@kvack.org>; Tue, 26 May 2009 17:19:51 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nXFwlXt+nJiP for <linux-mm@kvack.org>;
	Tue, 26 May 2009 17:19:51 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D441F82C42A
	for <linux-mm@kvack.org>; Tue, 26 May 2009 17:19:46 -0400 (EDT)
Date: Tue, 26 May 2009 17:05:45 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Warn if we run out of swap space
In-Reply-To: <20090526140110.c4a100fb.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.1.10.0905261703070.29789@gentwo.org>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <20090524144056.0849.A69D9226@jp.fujitsu.com> <4A1A057A.3080203@oracle.com> <20090526032934.GC9188@linux-sh.org> <alpine.DEB.1.10.0905261022170.7242@gentwo.org> <20090526131540.70fd410a.akpm@linux-foundation.org>
 <alpine.DEB.1.10.0905261653160.23631@gentwo.org> <20090526140110.c4a100fb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lethal@linux-sh.org, randy.dunlap@oracle.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, pavel@ucw.cz, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 2009, Andrew Morton wrote:

> On Tue, 26 May 2009 16:54:58 -0400 (EDT)
> Christoph Lameter <cl@linux.com> wrote:
>
> > On Tue, 26 May 2009, Andrew Morton wrote:
> >
> > > I still worry that there may be usage patterns which will result in
> > > this message coming out many times.
> >
> > Note that vm_swa_full is defined the following way
> >
> > #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
> >
> > This means that vm_swap_full is true when more than 50% of swap are in
> > use. The printed flag will therefore only be cleared if swap use falls to
> > less than half.
>
> (which was highly relevant changelog material)

I thought everyone knew since they were pointing to it. There is a comment
where vm_swap_full() is defined.

> OK.  But it that optimal?

Not sure but it certainly makes the messages rather infrequent. I would
personally be satisifed with a single message if it occurs for the first
time. Someone tinkering around with swap space is rare at least on
machines that are supposed to do real work and I really do not want
printk storms during development.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
