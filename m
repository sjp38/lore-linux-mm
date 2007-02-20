Message-ID: <45DB25E1.7030504@redhat.com>
Date: Tue, 20 Feb 2007 11:46:25 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] free swap space when (re)activating page
References: <45D63445.5070005@redhat.com> <Pine.LNX.4.64.0702192048150.9934@schroedinger.engr.sgi.com> <45DAF794.2000209@redhat.com> <Pine.LNX.4.64.0702200833460.13913@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702200833460.13913@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 20 Feb 2007, Rik van Riel wrote:
> 
>>> It was the portion that modifies shrink_active_list. Why operate
>>> on the pagevec there? The pagevec only contains the leftovers to be released
>>> from scanning over the temporary inactive list.
>> Why?  Because the pages that were not referenced will be
>> going onto the inactive list and are now a candidate for
>> swapping out.  I don't see why we would want to reclaim
>> the swap space for pages that area about to be swapped
>> out again.
> 
> Sounds sane. Then drop that piece. Again, you were only operating on the 
> pages left over in the pagevec after the move of the pages to the 
> inactive list. If you really wanted to do something there then the 
> processing should have covered all pages that go to the inactive list.

Nono, I try to remove the swap space occupied by pages that
go back onto the active list.  Regardless of whether they
were already there, or whether they started out on the
inactive list.

Stripping the swap space of the pages that are going to
the inactive list makes less sense IMHO, because those
pages are candidates for swapping out - meaning those
should keep the space.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
