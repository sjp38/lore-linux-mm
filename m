Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m7IApAOB078578
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 10:51:10 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7IApA5p2785478
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 11:51:10 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7IAp9Lw004873
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 11:51:10 +0100
Message-ID: <48A9541C.9050506@de.ibm.com>
Date: Mon, 18 Aug 2008 12:51:08 +0200
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] mm: xip/ext2 fix block allocation race
References: <20080818053821.GA3011@wotan.suse.de> <20080818054409.GB3011@wotan.suse.de> <20080818060301.GC3011@wotan.suse.de>
In-Reply-To: <20080818060301.GC3011@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, borntrae@linux.vnet.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> XIP can call into get_xip_mem concurrently with the same file,offset with
> create=1.  This usually maps down to get_block, which expects the page lock
> to prevent such a situation. This causes ext2 to explode for one reason or
> another.
> 
> Serialise those calls for the moment. For common usages today, I suspect
> get_xip_mem rarely is called to create new blocks. In future as XIP
> technologies evolve we might need to look at which operations require
> scalability, and rework the locking to suit.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
Acked-by: Carsten Otte <cotte@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
