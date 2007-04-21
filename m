Message-ID: <462A52BF.7000801@redhat.com>
Date: Sat, 21 Apr 2007 14:06:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com> <20070420135715.f6e8e091.akpm@linux-foundation.org> <462932BE.4020005@redhat.com> <Pine.LNX.4.64.0704210818580.25689@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0704210818580.25689@blonde.wat.veritas.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Fri, 20 Apr 2007, Rik van Riel wrote:
>> Andrew Morton wrote:
>>
>>>   I do go on about that.  But we're adding page flags at about one per
>>>   year, and when we run out we're screwed - we'll need to grow the
>>>   pageframe.
>> If you want, I can take a look at folding this into the
>> ->mapping pointer.  I can guarantee you it won't be
>> pretty, though :)
> 
> Please don't.  If we're going to stuff another pageflag into there,
> let it be PageSwapCache the natural partner of PageAnon, rather than
> whatever our latest pageflag happens to be. 

I looked at doing what Andrew wanted, and it did indeed not
look like the right thing to do.  The locking on page->mapping
is the kind of locking we want to avoid during zap_page_range
and in the pageout code.

I like your suggestion better.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
