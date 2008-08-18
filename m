Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m7IAoiBj192580
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 10:50:44 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7IAoiop3248254
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 11:50:44 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7IAoh5X003991
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 11:50:44 +0100
Message-ID: <48A95400.5050003@de.ibm.com>
Date: Mon, 18 Aug 2008 12:50:40 +0200
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] mm: xip fix fault vs sparse page invalidate race
References: <20080818053821.GA3011@wotan.suse.de> <20080818054409.GB3011@wotan.suse.de>
In-Reply-To: <20080818054409.GB3011@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, borntrae@linux.vnet.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> XIP has a race between sparse pages being inserted into page tables, and
> sparse pages being zapped when its time to put a non-sparse page in.
> 
> What can happen is that a process can be left with a dangling sparse page
> in a MAP_SHARED mapping, while the rest of the world sees the non-sparse
> version. Ie. data corruption. 
> 
> Guard these operations with a seqlock, making fault-in-sparse-pages
> the slowpath, and try-to-unmap-sparse-pages the fastpath.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
Ouch.
Acked-by: Carsten Otte <cotte@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
