Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1M4YE0X030746
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 10:04:14 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1M4YEI71028278
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 10:04:14 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1M4YD1Q016645
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 04:34:14 GMT
Message-ID: <47BE4FB5.5040902@linux.vnet.ibm.com>
Date: Fri, 22 Feb 2008 09:59:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] ResCounter: Use read_uint in memory controller
References: <20080221203518.544461000@menage.corp.google.com> <20080221205525.349180000@menage.corp.google.com>
In-Reply-To: <20080221205525.349180000@menage.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: akpm@linux-foundation.org, xemul@openvz.org, balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

menage@google.com wrote:
> Update the memory controller to use read_uint for its
> limit/usage/failcnt control files, calling the new
> res_counter_read_uint() function.
> 
> Signed-off-by: Paul Menage <menage@google.com>
> 

Hi, Paul,

Looks good, except for the name uint(), can we make it u64(). Integers are 32
bit on both ILP32 and LP64, but we really read/write 64 bit values.

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
