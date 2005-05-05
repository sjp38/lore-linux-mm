Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j45FilT9475080
	for <linux-mm@kvack.org>; Thu, 5 May 2005 11:44:47 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j45FikUA369406
	for <linux-mm@kvack.org>; Thu, 5 May 2005 09:44:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j45FikQR000351
	for <linux-mm@kvack.org>; Thu, 5 May 2005 09:44:46 -0600
Message-ID: <427A3F6A.6060405@austin.ibm.com>
Date: Thu, 05 May 2005 10:44:42 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: [1/3] add early_pfn_to_nid for ppc64
References: <E1DTQUL-0002WE-D6@pinky.shadowen.org>
In-Reply-To: <E1DTQUL-0002WE-D6@pinky.shadowen.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linuxppc64-dev@ozlabs.org, paulus@samba.org, anton@samba.org, linux-mm@kvack.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> +#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
> +#define early_pfn_to_nid(pfn)  pa_to_nid(((unsigned long)pfn) << PAGE_SHIFT)
> +#endif

Is there a reason we didn't just use pfn_to_nid() directly here instead 
of pa_to_nid()?  I'm just thinking of having DISCONTIG/NUMA off and 
pfn_to_nid() being #defined to zero for those cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
