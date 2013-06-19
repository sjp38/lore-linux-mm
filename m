Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 1C3BB6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 03:20:16 -0400 (EDT)
Message-ID: <51C15B7B.9060804@asianux.com>
Date: Wed, 19 Jun 2013 15:19:23 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmscan.c: 'lru' may be used without initialized after
 the patch "3abf380..." in next-20130607 tree
References: <51C155D1.3090304@asianux.com> <20130619001029.ee623fae.akpm@linux-foundation.org>
In-Reply-To: <20130619001029.ee623fae.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, hannes@cmpxchg.org, riel@redhat.com, mhocko@suse.cz, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 06/19/2013 03:10 PM, Andrew Morton wrote:
> On Wed, 19 Jun 2013 14:55:13 +0800 Chen Gang <gang.chen@asianux.com> wrote:
> 
>> > 
>> > 'lru' may be used without initialized, so need regressing part of the
>> > related patch.
>> > 
>> > The related patch:
>> >   "3abf380 mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru"
>> >
>> > ...
>> >
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -595,6 +595,7 @@ redo:
>> >  		 * unevictable page on [in]active list.
>> >  		 * We know how to handle that.
>> >  		 */
>> > +		lru = !!TestClearPageActive(page) + page_lru_base_type(page);
>> >  		lru_cache_add(page);
>> >  	} else {
>> >  		/*
> That looks right.  Why the heck didn't gcc-4.4.4 (at least) warn about it?
> 

Sorry I don't know either, I find it by reading code, this time.

It is really necessary to continue analyzing why. In 2nd half of 2013, I
have planned to make some patches outside kernel but related with kernel
(e.g. LTP, gcc patches).

This kind of issue is a good chance for me to start in 2nd half of 2013
(start from next month).

So if no others reply for it, I will start analyzing it in the next
month, and plan to finish within a month (before 2013-07-31).


Welcome additional suggestions or completions.

Thanks.
-- 
Chen Gang

Asianux Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
