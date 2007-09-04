Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l84J4h8L002562
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 15:04:43 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l84J3ImQ553410
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 15:03:18 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l84J3INu025578
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 15:03:18 -0400
Subject: Re: [-mm PATCH]  Memory controller improve user interface (v3)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070902105021.3737.31251.sendpatchset@balbir-laptop>
References: <20070902105021.3737.31251.sendpatchset@balbir-laptop>
Content-Type: text/plain
Date: Tue, 04 Sep 2007 12:03:13 -0700
Message-Id: <1188932593.28903.357.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2007-09-02 at 16:20 +0530, Balbir Singh wrote:
> 
> +Setting a limit to a number that is not a multiple of page size causes
> +rounding up of the value. The user must check back to see (by reading
> +memory.limit_in_bytes), to check for differences between desired values and
> +committed values. Currently, all accounting is done in multiples of PAGE_SIZE 

I wonder if we can say this in a bit more generic fashion.

        A successful write to this file does not guarantee a successful
        set of this limit to the value written into the file.  This can
        be due to a number of factors, such as rounding up to page
        boundaries or the total availability of memory on the system.
        The user is required to re-read this file after a write to
        guarantee the value committed by the kernel.

This keeps a user from saying "I page aligned the value I stuck in
there, no I don't have to check it."

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
