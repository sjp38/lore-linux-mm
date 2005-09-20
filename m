Received: from ccs-mail.lanl.gov (ccs-mail.lanl.gov [128.165.4.126])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with ESMTP id j8K41fxM017417
	for <linux-mm@kvack.org>; Mon, 19 Sep 2005 22:01:41 -0600
Subject: Re: [Question] How to understand Clock-Pro algorithm?
From: Song Jiang <sjiang@lanl.gov>
In-Reply-To: <432F7DD5.6050204@ccoss.com.cn>
References: <432F7DD5.6050204@ccoss.com.cn>
Content-Type: text/plain
Message-Id: <1127188898.3130.52.camel@moon.c3.lanl.gov>
Mime-Version: 1.0
Date: Mon, 19 Sep 2005 22:01:38 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: liyu <liyu@ccoss.com.cn>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-09-19 at 21:11, liyu wrote:

>     My question is out:As this paper words, the number of cold page is 
> total of resident cold pages
> and non-resident pages. It's the seem number of non-resident cold pages 
> can not beyond M at all!

You are right. So the total number of pages (non-resident + resident)
around the clock is no more than 2m 
(m is the memory size in pages).

>    
>     I also have more questions on CLOCK-Pro. but this question is most 
> doublt for me.
> 
  I am happy to help. I also have the clock-pro simulator that
almost exactly simulates what's described in the paper. Let me
know if you want it.

   Song Jiang

> 
> liyu
> 
>    
> 
> 
> 
>    
>    
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
