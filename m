Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m59HRHpu022803
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 22:57:17 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m59HQdXY876642
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 22:56:39 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m59HRHh8000543
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 22:57:17 +0530
Message-ID: <484D67EF.5090203@linux.vnet.ibm.com>
Date: Mon, 09 Jun 2008 22:57:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: 2.6.26-rc5-mm1
References: <20080609053908.8021a635.akpm@linux-foundation.org>
In-Reply-To: <20080609053908.8021a635.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Temporarily at
> 
>   http://userweb.kernel.org/~akpm/2.6.26-rc5-mm1/
> 

I've hit a segfault, the last few lines on my console are


Testing -fstack-protector-all feature
registered taskstats version 1
debug: unmapping init memory ffffffff80c03000..ffffffff80dd8000
init[1]: segfault at 7fff701fe880 ip 7fff701fee5e sp 7fff7006e6d0 error 7

With absolutely no stack trace. I'll dig deeper.

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
