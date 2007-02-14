Message-ID: <45D2D1F6.1020303@yahoo.com.au>
Date: Wed, 14 Feb 2007 20:10:14 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch] build error: allnoconfig fails on mincore/swapper_space
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com> <20070212150802.f240e94f.akpm@linux-foundation.org> <45D12715.4070408@yahoo.com.au> <20070213121217.0f4e9f3a.randy.dunlap@oracle.com> <Pine.LNX.4.64.0702132224280.3729@blonde.wat.veritas.com> <20070213144909.70943de2.randy.dunlap@oracle.com> <Pine.LNX.4.64.0702140009320.21315@blonde.wat.veritas.com> <45D266E3.4050905@yahoo.com.au> <Pine.LNX.4.64.0702140727180.4224@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0702140727180.4224@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, tony.luck@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 14 Feb 2007, Nick Piggin wrote:
> 
>>Can't you have migration without swap?
> 
> 
> Yes: but then the only swap entry it can find (short of page
> table corruption, which isn't really the focus of mincore)
> is a migration entry, isn't it?

Just doesn't seem logical to have CONFIG_SWAP ifdef cover the
whole thing, regardless that it produces the desired result.

I'm going to submit a fixup patch to Linus covering all this
stuff, after making a more comprehensive test case (yes I
actually did test this patch with a few different cases before
submitting it, so I must have been unlucky with uninitialised
data).

If he wants to apply it rather than back out the patch entirely,
its up to him.

I don't think there is any reason to panic. I did completely
forget the result vector, but AFAIKS that's the only real bug
in it.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
