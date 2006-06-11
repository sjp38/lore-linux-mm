Date: Sun, 11 Jun 2006 12:15:31 +0200 (MEST)
From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of
 physical pages backing it
In-Reply-To: <448A762F.7000105@yahoo.com.au>
Message-ID: <Pine.LNX.4.61.0606111215070.13585@yvahk01.tjqt.qr>
References: <1149903235.31417.84.camel@galaxy.corp.google.com>
 <448A762F.7000105@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: rohitseth@google.com, Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> There is currently /proc/<pid>/smaps that prints the detailed
>> information about the usage of physical pages but that is a very
>> expensive operation as it traverses all the PTs (for some one who is
>> just interested in getting that data for each vma).
>
> Yet more cacheline footprint in the page fault and unmap paths...
>
> What is this used for and why do we want it? Could you do some
> smaps-like interface that can work on ranges of memory, and
> continue to walk pagetables instead?
>
BTW, what is smaps used for (who uses it), anyway?


Jan Engelhardt
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
