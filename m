Message-ID: <441BC527.50400@yahoo.com.au>
Date: Sat, 18 Mar 2006 19:30:31 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] mm: swsusp shrink_all_memory tweaks
References: <200603101704.AA00798@bbb-jz5c7z9hn9y.digitalinfra.co.jp> <200603181556.23307.kernel@kolivas.org> <441B9E5A.1040703@yahoo.com.au> <200603181714.23977.kernel@kolivas.org>
In-Reply-To: <200603181714.23977.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, ck@vds.kolivas.org, Andreas Mohr <andi@rhlx01.fht-esslingen.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Machek <pavel@suse.cz>, Stefan Seyfried <seife@suse.de>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> cc'ed GregKH for comment hopefully.

>>You did the right thing there by introducing the accessor, which moves the
>>ifdef out of code that wants to query the member right? But you can still
>>leave it in the .c file if it is local (which it is).
> 
> 
> Once again I'm happy to do the right thing; I'm just not sure what that is.
> 

Well, struct scan_control escaping from vmscan.c is not the right thing
(try to get that past Andrew!). Obviously in this case, having the ifdef
in the .c file is OK.

I guess Greg's presentation is a first order approximation to get people
thinking in the right way. I mean we do it all the time, and in core kernel
code too (our favourite sched.c is a prime example).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
