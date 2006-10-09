Message-ID: <452A4A9D.40605@yahoo.com.au>
Date: Mon, 09 Oct 2006 23:11:57 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] memory page alloc minor cleanups
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
In-Reply-To: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, David Rientjes <rientjes@google.com>, Andi Kleen <ak@suse.de>, mbligh@google.com, rohitseth@google.com, menage@google.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> From: Paul Jackson <pj@sgi.com>
> 
> While coding up various alternative performance improvements
> to the zonelist scanning below __alloc_pages(), I tripped
> over a few minor code style and layout nits in mm/page_alloc.c
> 
> I noticed that Nick had a couple of these same nits in one of
> his patches - so I hesitate to push this patch without sync'ing
> with him, to minimize conflicts over more important patches.

Ah, syncing up won't be difficult.

> 
> The removal of the NULL zone check needs approval by someone
> who knows this code better than I do -- I could have broken
> something with this change.
> 
> Changes include:
>  1) s/freeliest/freelist/ spelling fix
>  2) Check for NULL *z zone seems useless - even if it could
>     happen, so what?  Perhaps we should have a check later on
>     if we are faced with an allocation request that is not
>     allowed to fail - shouldn't that be a serious kernel error,
>     passing an empty zonelist with a mandate to not fail?

Would it be better to ensure an empty zonelist is never passed down?

Otherwise, it's fine by me.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
