Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 901B16B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 20:29:59 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G1TuP8008524
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Feb 2010 10:29:56 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E759445DE5B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 10:29:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B335145DE57
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 10:29:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 59A821DB803F
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 10:29:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D62E8EF8003
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 10:29:54 +0900 (JST)
Date: Tue, 16 Feb 2010 10:26:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm: add comment about deprecation of __GFP_NOFAIL
Message-Id: <20100216102626.5f6f0e11.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002151712290.23480@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151419260.26927@chino.kir.corp.google.com>
	<20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
	<20100216092147.85ef7619.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002151712290.23480@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010 17:13:57 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 16 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > As I already explained when you first brought this up, the possibility of 
> > > not invoking the oom killer is not unique to GFP_DMA, it is also possible 
> > > for GFP_NOFS.  Since __GFP_NOFAIL is deprecated and there are no current 
> > > users of GFP_DMA | __GFP_NOFAIL, that warning is completely unnecessary.  
> > > We're not adding any additional __GFP_NOFAIL allocations.
> > >
> > 
> > Please add documentation about that to gfp.h before doing this.
> > Doing this without writing any documenation is laziness.
> > (WARNING is a style of documentation.)
> > 
> 
> This is already documented in the page allocator, but I guess doing it in 
> include/linux/gfp.h as well doesn't hurt.
> 
I want warning when someone uses OBSOLETE interface but...

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I hope no 3rd vendor (proprietary) driver uses __GFP_NOFAIL, they tend to
believe API is trustable and unchanged.

> 
> 
> mm: add comment about deprecation of __GFP_NOFAIL
> 
> __GFP_NOFAIL was deprecated in dab48dab, so add a comment that no new 
> users should be added.
> 
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  include/linux/gfp.h |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -30,7 +30,8 @@ struct vm_area_struct;
>   * _might_ fail.  This depends upon the particular VM implementation.
>   *
>   * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
> - * cannot handle allocation failures.
> + * cannot handle allocation failures.  This modifier is deprecated and no new
> + * users should be added.
>   *
>   * __GFP_NORETRY: The VM implementation must not retry indefinitely.
>   *
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
