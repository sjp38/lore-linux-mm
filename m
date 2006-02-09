Message-ID: <43EAD524.6020105@yahoo.com.au>
Date: Thu, 09 Feb 2006 16:37:40 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Removing page->flags
References: <1139381183.22509.186.camel@localhost>	 <43E9DBE8.8020900@yahoo.com.au>	 <aec7e5c30602081835s8870713qa40a6cf88431cad1@mail.gmail.com>	 <43EAC2CE.2010108@yahoo.com.au> <aec7e5c30602082119v4127aa92ga3c9d9ba6dee0378@mail.gmail.com>
In-Reply-To: <aec7e5c30602082119v4127aa92ga3c9d9ba6dee0378@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

Magnus Damm wrote:

> But introducing a second page->flags is out of the question, and
> breaking out flags and placing a pointer to them in the node data
> structure will introduce more cache misses. So it is probably not
> worth it.
> 

Yep. Even then, you can't simply have a single non-atomic flags word,
unless _all_ flags are protected by the same lock.

>>
>>It seems pretty unlikely that we'll get a pluggable replacement
>>policy in mainline any time soon though.
> 
> 
> So, do you think it is more likely that a ClockPro implementation will
> be accepted then? Or is Linux "doomed" to LRU forever?
> 

I think (hope) that Linux eventually (if slowly) moves toward the best
implementation available. I just don't think there will be sufficient
justification for a pluggable page reclaim infrastructure in the mainline
kernel.

Cheers,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
