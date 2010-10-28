Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C93396B0095
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 08:12:53 -0400 (EDT)
Date: Thu, 28 Oct 2010 08:12:40 -0400
From: William Thompson <wt@electro-mechanical.com>
Subject: Re: OOM help
Message-ID: <20101028121240.GA14603@electro-mechanical.com>
References: <20100915120349.GH29041@electro-mechanical.com> <20100916164231.3BC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100916164231.3BC3.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 17, 2010 at 09:39:11AM +0900, KOSAKI Motohiro wrote:
> Hi William
> 
> That said, there are two possibility.
>  1) your kernel (probably drivers) have memory leak
>  2) you are using really lots of GFP_KERNEL memory. and then, you need to switch 64bit kernel
> 
> 
> Can you please try latest kernel and try reproduce? I'm curios two point.
> 1) If latest doesn't OOM, the leak has been fixed already. 2) If the OOM occur,
> latest output more detailed information.
> 
> But, if you want asap solution, I recommend to try 64bit kernel.

I'm having the problem again.  This time, I'm using 2.6.35.4.  Would
changing from 1gb kernel/3gb user to 2gb/2gb help?  I don't believe I
actually use more than 1gb or so of user space memory anyway.

64-bit would require that I completely reinstall this system which is
definately not something I want to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
