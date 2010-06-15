Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CC3C36B025B
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:14:19 -0400 (EDT)
Message-ID: <4C17D0C5.9030203@redhat.com>
Date: Tue, 15 Jun 2010 15:13:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100615140011.GD28052@random.random> <20100615141122.GA27893@infradead.org> <20100615142219.GE28052@random.random> <20100615144342.GA3339@infradead.org> <20100615150850.GF28052@random.random> <20100615152526.GA3468@infradead.org> <20100615154516.GG28052@random.random> <20100615162600.GA9910@infradead.org> <4C17AF2D.2060904@redhat.com> <20100615165423.GA16868@infradead.org>
In-Reply-To: <20100615165423.GA16868@infradead.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/15/2010 12:54 PM, Christoph Hellwig wrote:
> On Tue, Jun 15, 2010 at 12:49:49PM -0400, Rik van Riel wrote:
>> This is already in a filesystem.  Why does ->writepage get
>> called a second time?  Shouldn't this have a gfp_mask
>> without __GFP_FS set?
>
> Why would it?  GFP_NOFS is not for all filesystem code, but only for
> code where we can't re-enter the filesystem due to deadlock potential.

Why?   How about because you know the stack is not big enough
to have the XFS call path on it twice? :)

Isn't the whole purpose of this patch series to prevent writepage
from being called by the VM, when invoked from a deep callstack
like xfs writepage?

That sounds a lot like simply wanting to not have GFP_FS...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
