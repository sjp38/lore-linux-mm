Date: Tue, 01 Jul 2003 13:10:39 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <445820000.1057090239@flay>
In-Reply-To: <200306301943.04326.phillips@arcor.de>
References: <Pine.LNX.4.53.0307010238210.22576@skynet> <200306301943.04326.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

>>    In 2.4, Page Table Entries (PTEs) must be allocated from ZONE_ NORMAL as
>>    the kernel needs to address them directly for page table traversal. In a
>>    system with many tasks or with large mapped memory regions, this can
>>    place significant pressure on ZONE_ NORMAL so 2.6 has the option of
>>    allocating PTEs from high memory.
> 
> You probably ought to mention that this is only needed by 32 bit architectures 
> with silly amounts of memory installed. 

Actually, it has more to do with the number of processes sharing data,
than the amount of memory in the machine. And that's only because we 
insist on making duplicates of identical pagetables all over the place ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
