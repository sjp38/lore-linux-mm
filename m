Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4A6448D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 13:04:18 -0500 (EST)
Message-ID: <4D430506.2070502@redhat.com>
Date: Fri, 28 Jan 2011 13:03:50 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: too big min_free_kbytes
References: <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110127160301.GA29291@csn.ul.ie> <20110127185215.GE16981@random.random> <20110127213106.GA25933@csn.ul.ie> <4D41FD2F.3050006@redhat.com> <20110128103539.GA14669@csn.ul.ie> <20110128162831.GH16981@random.random> <20110128164624.GA23905@csn.ul.ie> <4D42F9E3.2010605@redhat.com> <20110128174644.GM16981@random.random>
In-Reply-To: <20110128174644.GM16981@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On 01/28/2011 12:46 PM, Andrea Arcangeli wrote:

> My whole point in claiming it can't affect the balancing of the lrus,
> is that the real lru rotation is entirely controlled by the
> allocator. It doesn't matter if kswapd stops at high or high+gap, for
> any zone at any time, as long as the allocator only allocates from one
> zone or the other. And if the allocator allocates from all zones in a
> perfectly balanced way, again kswapd will shrink in a perfectly
> balanced way over time regardless of high or high+gap.

My point is, the behaviour you describe would be WRONG :)

The reason is that the different zones can contain data
that is either heavily used or rarely used, often some
mixture of the two, but sometimes the zones are out of
balance in how much the data in memory gets touched.

We need to reclaim and reuse the lightly used memory
a little faster than the heavily used memory, to even
out the memory pressure between zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
