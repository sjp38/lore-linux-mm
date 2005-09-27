Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8RGHmSZ021642
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 12:17:48 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8RGHmrv087150
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 12:17:48 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8RGHlfa004504
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 12:17:48 -0400
Message-ID: <433970A9.6010409@austin.ibm.com>
Date: Tue, 27 Sep 2005 11:17:45 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/9] try harder on large allocations
References: <4338537E.8070603@austin.ibm.com> <433856B2.8030906@austin.ibm.com> <2cd57c90050927002163f78269@mail.gmail.com>
In-Reply-To: <2cd57c90050927002163f78269@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Coywolf Qi Hunt <coywolf@gmail.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

>>+               if (order < MAX_ORDER/2) out_of_memory(gfp_mask, order);
> 
> 
> Shouldn't that be written in two lines?

Yes, fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
