Message-ID: <40273002.9080007@cyberone.com.au>
Date: Mon, 09 Feb 2004 18:00:18 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm improvements
References: <Pine.LNX.4.44.0402041444560.24515-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0402041444560.24515-100000@chimarrao.boston.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Rik van Riel wrote:

> On Wed, 4 Feb 2004, Nick Piggin wrote:
>
>> > 1/5: vm-no-rss-limit.patch
>> >     Remove broken RSS limiting. Simple problem, Rik is onto it.
>> >
>
>
> Does the patch below fix the performance problem with the
> rss limit patch ?
>
>

Sorry I missed this Rik. The rsslimit patch is now too old
to apply to the mm tree because of one of my patches.

To fix this you need to be able to check rsslimit before
clearing referenced bits, and possibly not clear referenced
bit at all.

Its obviously inefficient to do to check ptes twice, so probably
just doing it once would be OK, you'd just need to do something
like:

if (referenced && dont_clear_referenced)
    SetPageReferenced(page);

at the end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
