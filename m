Message-ID: <46F19ED6.20501@redhat.com>
Date: Wed, 19 Sep 2007 18:12:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: VM/VFS bug with large amount of memory and file systems?
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>	<1189850897.21778.301.camel@twins>	<20070915035228.8b8a7d6d.akpm@linux-foundation.org>	<13126578-A4F8-43EA-9B0D-A3BCBFB41FEC@cam.ac.uk>	<20070917163257.331c7605@twins>	<46EEB532.3060804@redhat.com>	<20070917131526.e8db80fe.akpm@linux-foundation.org>	<46EEE7B7.1070206@redhat.com> <20070917141127.ab2ae148.akpm@linux-foundation.org>
In-Reply-To: <20070917141127.ab2ae148.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Anton Altaparmakov <aia21@cam.ac.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, marc.smith@esmail.mcc.edu
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 17 Sep 2007 16:46:47 -0400
> Rik van Riel <riel@redhat.com> wrote:

>> Is the slab defragmentation code in -mm or upstream already
>> or can I find it on the mailing list?
> 
> Is on lkml and linux-mm: http://lkml.org/lkml/2007/8/31/329

> I think the whole approach is reasonable.  It's mainly a matter of going
> through it all with a toothcomb 

I've spent the last two days combing through the patches.

Except for the one doubt I had (resolved in email), and
one function name comment (on patch 18/26) the code looks
good to me.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
