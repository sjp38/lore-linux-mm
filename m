Received: from ccs-mail.lanl.gov (ccs-mail.lanl.gov [128.165.4.126])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with ESMTP id j8K5Gebn018481
	for <linux-mm@kvack.org>; Mon, 19 Sep 2005 23:16:40 -0600
Subject: Re: [Question] How to understand Clock-Pro algorithm?
From: Song Jiang <sjiang@lanl.gov>
In-Reply-To: <432F97E1.4080805@ccoss.com.cn>
References: <432F7DD5.6050204@ccoss.com.cn>
	 <1127188898.3130.52.camel@moon.c3.lanl.gov> <432F97E1.4080805@ccoss.com.cn>
Content-Type: text/plain
Message-Id: <1127193398.3130.131.camel@moon.c3.lanl.gov>
Mime-Version: 1.0
Date: Mon, 19 Sep 2005 23:16:38 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: liyu <liyu@ccoss.com.cn>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-09-19 at 23:02, liyu wrote:

> 
>     Let's assume Mn is the total number of non-resident pages in follow 
> words.
> 
>     Nod, 'M=Mh+Mc' and 'Mc+Mn' < 2M are always true.
> 
>     Have this implied that Mn is alway less than M? I think so.
    Yes.

> 
>     but if "Once the number exceeds M the memory size in number of pages,
> we terminted the test period of the cold page pointed to by HAND-test."
> 
>     If Mn is alway less than M, when we move to HAND-test?

The algorithm tries to ensure that Mn <= M holds. 
Once Mn == M+1 is detected, run HAND-test to bring it
back to Mn == M. That is, only during the transition period, 
Mn <= M might not hold, and we make a correction quickly.

So there is no contradiction here.
   Song

> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
