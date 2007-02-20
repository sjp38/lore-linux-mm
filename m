Message-ID: <45DAF794.2000209@redhat.com>
Date: Tue, 20 Feb 2007 08:28:52 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] free swap space when (re)activating page
References: <45D63445.5070005@redhat.com> <Pine.LNX.4.64.0702192048150.9934@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702192048150.9934@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 16 Feb 2007, Rik van Riel wrote:
> 
>> What do you think?
> 
> Looks good apart from one passage (which just vanished when I tried to 
> reply, please post patches as inline text).
> 
> It was the portion that modifies shrink_active_list. Why operate
> on the pagevec there? The pagevec only contains the leftovers to be 
> released from scanning over the temporary inactive list.

Why?  Because the pages that were not referenced will be
going onto the inactive list and are now a candidate for
swapping out.  I don't see why we would want to reclaim
the swap space for pages that area about to be swapped
out again.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
