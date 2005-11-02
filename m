Message-ID: <43687DC7.3060904@yahoo.com.au>
Date: Wed, 02 Nov 2005 19:50:15 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <E1EXDKN-0004b9-00@w-gerrit.beaverton.ibm.com>
In-Reply-To: <E1EXDKN-0004b9-00@w-gerrit.beaverton.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gh@us.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Gerrit Huizenga wrote:

> So, people are working towards two distinct solutions, both of which
> require us to do a better job of defragmenting memory (or avoiding
> fragementation in the first place).
> 

This is just going around in circles. Even with your fragmentation
avoidance and memory defragmentation, there are still going to be
cases where memory does get fragmented and can't be defragmented.
This is Ingo's point, I believe.

Isn't the solution for your hypervisor problem to dish out pages of
the same size that are used by the virtual machines. Doesn't this
provide you with a nice, 100% solution that doesn't add complexity
where it isn't needed?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
