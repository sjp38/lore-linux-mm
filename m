Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RH5Kjk007076
	for <linux-mm@kvack.org>; Tue, 27 May 2008 13:05:20 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RH596l081664
	for <linux-mm@kvack.org>; Tue, 27 May 2008 13:05:10 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RH598I004609
	for <linux-mm@kvack.org>; Tue, 27 May 2008 13:05:09 -0400
Date: Tue, 27 May 2008 10:05:07 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 13/23] hugetlb: printk cleanup
Message-ID: <20080527170507.GH20709@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143453.486886000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525143453.486886000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On 26.05.2008 [00:23:30 +1000], npiggin@suse.de wrote:
> - Reword sentence to clarify meaning with multiple options
> - Add support for using GB prefixes for the page size
> - Add extra printk to delayed > MAX_ORDER allocation code
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
