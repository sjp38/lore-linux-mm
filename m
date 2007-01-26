Message-ID: <45BA747F.8040005@nortel.com>
Date: Fri, 26 Jan 2007 15:37:03 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] Allow huge page allocations to use GFP_HIGH_MOVABLE
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie> <20070125234558.28809.21103.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0701260832260.6141@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0701261649040.23091@skynet.skynet.ie> <Pine.LNX.4.64.0701260903110.6966@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0701261720120.23091@skynet.skynet.ie> <Pine.LNX.4.64.0701260921310.7301@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0701261727400.23091@skynet.skynet.ie> <Pine.LNX.4.64.0701260944270.7457@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0701261747290.23091@skynet.skynet.ie> <45BA49F2.2000804@nortel.com> <Pine.LNX.4.64.0701262038120.23091@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0701262038120.23091@skynet.skynet.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Fri, 26 Jan 2007, Chris Friesen wrote:

>> We currently see this issue on our systems, as we have older e1000 
>> hardware with 9KB jumbo frames.  After a while we just fail to 
>> allocate buffers and the system goes belly-up.

> Can you describe a reliable way of triggering this problem? At best, I 
> hear "on our undescribed workload, we sometimes see this problem" but 
> not much in the way of details.

I work on embedded server applications.  One of our blades is a 
dual-Xeon with 8GB of RAM and 6 e1000 cards.  The hardware is 32-bit 
only, so we're using the i386 kernel with HIGHMEM64G enabled.

This blade acts essentially as storage for other blades in the shelf. 
Basically all disk and network I/O.  After being up for a month or two 
it starts getting e1000 allocation failures.  In some of the cases at 
least it appears that the page cache has hundreds of megs of freeable 
memory, but it can't get at that memory to fulfill an atomic allocation.

I should point out that we haven't yet tried tuning 
/proc/sys/vm/min_free_kbytes.  The default value on this system is 3831.

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
