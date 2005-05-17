Message-ID: <4289FCB7.9080007@shadowen.org>
Date: Tue, 17 May 2005 15:16:23 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Factor in buddy allocator alignment requirements in node
 memory alignment
References: <Pine.LNX.4.62.0505161204540.4977@ScMPusgw> <1116274451.1005.106.camel@localhost> <Pine.LNX.4.62.0505161240240.13692@ScMPusgw> <1116276439.1005.110.camel@localhost> <20050517131202.GQ26073@g5.random>
In-Reply-To: <20050517131202.GQ26073@g5.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Dave Hansen <haveblue@us.ibm.com>, christoph <christoph@scalex86.org>, linux-mm <linux-mm@kvack.org>, shai@scalex86.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Mon, May 16, 2005 at 01:47:19PM -0700, Dave Hansen wrote:
> 
>>Just because it complains doesn't mean that anything is actually
>>wrong :)
>>
>>Do you know which pieces of code actually break if the alignment doesn't
>>meet what that warning says?
> 
> 
> Be sure in early 2001 the alpha wildfire wasn't booting without having
> natural alingment from the 2^order allocation, after several days of
> debugging and crashing eventually I figured it out and added the printk
> (it couldn't be a BUG since it was early in the boot to see it). The
> kernel stack on x86 w/o 4k stacks depends on the natural alignment of
> the 2^order buddy allocations for example. No idea how much other code
> would break with not naturally aligned 2^order allocations.

Absolutly there are cases which will break if the alignment of
allocations arn't correct.  The key here is the free algorithm will now
correctly merge buddies at the physical alignement.  This allows the
boundries of the zones to be miss-aligned.  Partial pages simply have no
buddies at the nigher level and do not coalesce.  The warning is
checking for such a miss-alignment and now is no longer required.

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
