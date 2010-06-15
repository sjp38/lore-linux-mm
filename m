Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5AAA16B0247
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 10:55:58 -0400 (EDT)
Message-ID: <4C17945A.5070500@redhat.com>
Date: Tue, 15 Jun 2010 10:55:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100615140011.GD28052@random.random> <20100615145134.GM26788@csn.ul.ie>
In-Reply-To: <20100615145134.GM26788@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/15/2010 10:51 AM, Mel Gorman wrote:
> On Tue, Jun 15, 2010 at 04:00:11PM +0200, Andrea Arcangeli wrote:
>> Hi Mel,
>>
>> I know lots of people doesn't like direct reclaim,
>
> It's not direct reclaim that is the problem per-se, it's direct reclaim
> calling writepage and splicing two potentially deep call chains
> together.

I have talked to Mel on IRC, and the above means:

"calling alloc_pages from an already deep stack frame,
  and then going into direct reclaim"

That explanation would have been helpful in email :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
