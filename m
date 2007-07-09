Message-ID: <4691E8D1.4030507@yahoo.com.au>
Date: Mon, 09 Jul 2007 17:50:41 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: zone movable patches comments
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

Just had a bit of a look at the zone movable stuff in -mm... Firstly,
would it be possible to list all the dependant patches in that set, or
is it just those few that are contiguous in Andrew's series file?

A few comments -- can it be made configurable? I guess there is not
much overhead if the zone is not populated, but there has been a fair
bit of work towards taking out unneeded zones.

Also, I don't really like the name kernelcore= to specify mem-sizeof
movable zone. Could it be renamed and stated in the positive, like
movable_mem= or reserve_movable_mem=? And can that option be written
up in Documentation?

What is the status of these patches? Are they working and pretty well
ready to be merged for 2.6.23?

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
