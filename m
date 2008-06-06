Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m564G9RJ013561
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 14:16:09 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m564G0OU4620302
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 14:16:00 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m564GHZb020886
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 14:16:17 +1000
Message-ID: <4848B9B7.2000208@linux.vnet.ibm.com>
Date: Fri, 06 Jun 2008 09:44:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 3/3 v2] per-task-delay-accounting: update document and
 getdelays.c for memory reclaim
References: <20080605162759.a6adf291.kobayashi.kk@ncos.nec.co.jp> <20080605163338.8880eb7f.kobayashi.kk@ncos.nec.co.jp>
In-Reply-To: <20080605163338.8880eb7f.kobayashi.kk@ncos.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nagar@watson.ibm.com, balbir@in.ibm.com, sekharan@us.ibm.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Keika Kobayashi wrote:
> Update document and make getdelays.c show delay accounting for memory reclaim.
> 
> For making a distinction between "swapping in pages" and "memory reclaim"
> in getdelays.c, MEM is changed to SWAP.
> 
> Signed-off-by: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>

Looks good

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
