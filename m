Message-ID: <48FDE9E9.5020805@redhat.com>
Date: Tue, 21 Oct 2008 10:40:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [rfc] mm: more likely reclaim MADV_SEQUENTIAL mappings
References: <87d4hugrwm.fsf@saeurebad.de>
In-Reply-To: <87d4hugrwm.fsf@saeurebad.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:

> I'm afraid this is now quite a bit more aggressive than the earlier
> version.  When the fault path did a mark_page_access(), we wouldn't
> reclaim a page when it has been faulted into several MADV_SEQUENTIAL
> mappings but now we ignore *every* activity through such a mapping.
> 
> What do you think?
> 
> Perhaps we should note a reference if there are two or more accesses
> through sequentially read mappings?

That can be easily accomplished by dropping the memory.c
part of your patch.

I do not know whether that would work any better than
the patch you just posted, though :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
