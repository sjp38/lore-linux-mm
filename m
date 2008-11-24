Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAOKDO9d012323
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 15:13:24 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAOKE432168894
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 15:14:04 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAOLECpr019590
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 16:14:13 -0500
Date: Mon, 24 Nov 2008 12:14:02 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] hugetlb: fix sparse warnings
Message-ID: <20081124201402.GA8284@us.ibm.com>
References: <154e089b0811241205m293b5824of0fa753c1f8c33a6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154e089b0811241205m293b5824of0fa753c1f8c33a6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hannes Eder <hannes@hanneseder.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 24.11.2008 [21:05:31 +0100], Hannes Eder wrote:
> Impact: fix sparse warnings
> 
> Fix the following sparse warnings:
> 
>   mm/hugetlb.c:375:3: warning: returning void-valued expression
>   mm/hugetlb.c:408:3: warning: returning void-valued expression
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
