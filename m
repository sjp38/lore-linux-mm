From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [rfc] mm: more likely reclaim MADV_SEQUENTIAL mappings
References: <87d4hugrwm.fsf@saeurebad.de> <48FDE9E9.5020805@redhat.com>
Date: Tue, 21 Oct 2008 17:20:18 +0200
In-Reply-To: <48FDE9E9.5020805@redhat.com> (Rik van Riel's message of "Tue, 21
	Oct 2008 10:40:41 -0400")
Message-ID: <874p36gekt.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@redhat.com> writes:

> Johannes Weiner wrote:
>
>> I'm afraid this is now quite a bit more aggressive than the earlier
>> version.  When the fault path did a mark_page_access(), we wouldn't
>> reclaim a page when it has been faulted into several MADV_SEQUENTIAL
>> mappings but now we ignore *every* activity through such a mapping.
>>
>> What do you think?
>>
>> Perhaps we should note a reference if there are two or more accesses
>> through sequentially read mappings?
>
> That can be easily accomplished by dropping the memory.c
> part of your patch.

I thought about that, but wouldn't we count a reference in the chain

        fault -> unmap -> page_referenced()

opposed to counting _no_ reference in

        fault -> page_referenced() -> ... -> unmap

?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
