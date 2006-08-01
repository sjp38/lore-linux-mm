Message-ID: <44CFE98D.2060901@yahoo.com.au>
Date: Wed, 02 Aug 2006 09:53:49 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm: speculative get_page
References: <20060801193203.GA191@oleg> <1154447729.10401.16.camel@kleikamp.austin.ibm.com> <20060801204202.GA223@oleg>
In-Reply-To: <20060801204202.GA223@oleg>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Dave Kleikamp <shaggy@austin.ibm.com>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Oleg Nesterov wrote:
> On 08/01, Dave Kleikamp wrote:

>>Isn't the page locked when calling remove_mapping()?  It looks like
>>SetPageNoNewRefs & ClearPageNoNewRefs are called in safe places.  Either
>>the page is locked, or it's newly allocated.  I could have missed
>>something, though.
> 
> 
> No, I think it is I who missed something, thanks.

Yeah, SetPageNoNewRefs is indeed called only under PageLocked or for
newly allocated pages. I should make a note about that, as it isn't
immediately clear.

Thanks

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
