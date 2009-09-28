Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B35E06B0095
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:01:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8S4tXn9011606
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Sep 2009 13:55:33 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 22D8045DE57
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 13:55:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0401645DE55
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 13:55:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DEE731DB8038
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 13:55:32 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 81062E78001
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 13:55:32 +0900 (JST)
Date: Mon, 28 Sep 2009 13:53:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: No more bits in vm_area_struct's vm_flags.
Message-Id: <20090928135315.083aca18.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4AC03D9C.3020907@crca.org.au>
References: <4AB9A0D6.1090004@crca.org.au>
	<20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>
	<4ABC80B0.5010100@crca.org.au>
	<20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>
	<4AC0234F.2080808@crca.org.au>
	<20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090928033624.GA11191@localhost>
	<20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com>
	<4AC03D9C.3020907@crca.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Sep 2009 14:37:48 +1000
Nigel Cunningham <ncunningham@crca.org.au> wrote:

> Hi.
> 
> KAMEZAWA Hiroyuki wrote:
> > Then, Nigel, you have 2 choices I think.
> > 
> > (1) don't merge if vm_hints is set  or (2) pass vm_hints to all
> > __merge() functions.
> > 
> > One of above will be accesptable for stakeholders... I personally
> > like (1) but just trying (2) may be accepted.
> > 
> > What I dislike is making vm_flags to be long long ;)
> 
> Okay. I've gone for option 1 for now. Here's what I
> currently have (compile testing as I write)...
> 
> 
> 
> vm_flags in struct vm_area_struct is full. Move some of the less commonly
> used flags to a new variable so that other flags that need to be in vm_flags
> (because, for example, they need to be in variables that are passed around)
> can be added.
> 
> Signed-off-by: Nigel Cunningham <nigel@tuxonice.net>

Seems good to me.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
But
> +	if (vma->vm_hints)
> +		return 0;
>  	return 1;

Maybe adding a comment (or more detailed patch description) is necessary.

Regards,
-Kame

>  }
>  
> -- 
> 1.6.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
