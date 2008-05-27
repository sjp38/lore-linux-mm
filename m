Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RLWWF1002959
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:32:32 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RLUBPX133530
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:30:11 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RLUAuZ025372
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:30:11 -0400
Subject: Re: [patch 13/23] hugetlb: printk cleanup
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143453.486886000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143453.486886000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 16:30:10 -0500
Message-Id: <1211923810.12036.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi-suse@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> plain text document attachment (hugetlb-printk-cleanup.patch)
> - Reword sentence to clarify meaning with multiple options
> - Add support for using GB prefixes for the page size
> - Add extra printk to delayed > MAX_ORDER allocation code
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
