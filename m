From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch 2/3] swap: refactor pagevec flushing
References: <20081022225006.010250557@saeurebad.de>
	<20081022225512.879260477@saeurebad.de>
	<20081026235011.8af44857.akpm@linux-foundation.org>
Date: Mon, 27 Oct 2008 09:08:55 +0100
In-Reply-To: <20081026235011.8af44857.akpm@linux-foundation.org> (Andrew
	Morton's message of "Sun, 26 Oct 2008 23:50:11 -0700")
Message-ID: <877i7uihns.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 23 Oct 2008 00:50:08 +0200 Johannes Weiner <hannes@saeurebad.de> wrote:
>
>> Having all pagevecs in one array allows for easier flushing.  Use a
>> single flush function that decides what to do based on the target LRU.
>> 
>> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
>> ---
>>  include/linux/pagevec.h |   13 +++--
>>  mm/swap.c               |  121 +++++++++++++++++++++++-------------------------
>>  2 files changed, 66 insertions(+), 68 deletions(-)
>> 
>> --- a/include/linux/pagevec.h
>> +++ b/include/linux/pagevec.h
>> @@ -27,10 +27,13 @@ enum lru_pagevec {
>>  	NR_LRU_PAGEVECS
>>  };
>>  
>> +#define for_each_lru_pagevec(pv)		\
>> +	for (pv = 0; pv < NR_LRU_PAGEVECS; pv++)
>
> This only gets used once.  I don't think it's existence is justified?

I don't see any other use-case for it now.  So, yes, let's drop it.

> (`pv' is usally parenthesised in macros like this, but it's unlikely to
> matter).

Hmm, wondering which valid lvalue construction could break it...?
Probably something involving stars...

Okay, get doubly rid of it.  Replacement patch coming soon.

        Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
