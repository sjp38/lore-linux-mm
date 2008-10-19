From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
References: <20081015162232.f673fa59.akpm@linux-foundation.org>
	<200810181230.33688.nickpiggin@yahoo.com.au>
	<87fxmu41wt.fsf@saeurebad.de>
	<200810191321.25490.nickpiggin@yahoo.com.au>
Date: Sun, 19 Oct 2008 16:39:31 +0200
In-Reply-To: <200810191321.25490.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Sun, 19 Oct 2008 13:21:25 +1100")
Message-ID: <87skqshcnw.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

>> >> Another access would mean another young PTE, which we will catch as a
>> >> proper reference sooner or later while walking the mappings, no?
>> >
>> > No. Another access could come via read/write, or be subsequently unmapped
>> > and put into PG_referenced.
>>
>> read/write use mark_page_accessed(), so after having two accesses, the
>> page is already active.  If it's not and we find an access through a
>> sequential mapping, we should be safe to clear PG_referenced.
>
> That's just handwaving. The patch still clears PG_referenced, which
> is a shared resource, and it is wrong, conceptually. You can't argue
> with that.
>
> What about if mark_page_accessed is only used on the page once? and
> it is referenced but not active?

I see the problem now, thanks for not giving up ;) Fixing up the fault
paths and moving their mark_page_accessed to the unmap side seems like a
good idea.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
