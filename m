Message-ID: <441B9E5A.1040703@yahoo.com.au>
Date: Sat, 18 Mar 2006 16:44:58 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] mm: swsusp shrink_all_memory tweaks
References: <200603101704.AA00798@bbb-jz5c7z9hn9y.digitalinfra.co.jp> <200603181546.20794.kernel@kolivas.org> <441B9205.5010701@yahoo.com.au> <200603181556.23307.kernel@kolivas.org>
In-Reply-To: <200603181556.23307.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, ck@vds.kolivas.org, Andreas Mohr <andi@rhlx01.fht-esslingen.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Machek <pavel@suse.cz>, Stefan Seyfried <seife@suse.de>
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> On Saturday 18 March 2006 15:52, Nick Piggin wrote:
> 
>>Con Kolivas wrote:
>>
>>>
>>>#ifdeffery
>>
>>Sorry I don't understand...
> 
> 
> My bad.
> 
> I added the suspend_pass member to struct scan_control within an #ifdef 
> CONFIG_PM to allow it to not be unnecessarily compiled in in the !CONFIG_PM 
> case and wanted to avoid having the #ifdefs in vmscan.c so moved it to a 
> header file.
> 

Oh no, that rule thumb isn't actually "don't put ifdefs in .c files", but
people commonly say it that way anyway. The rule is actually that you should
put ifdefs in declarations rather than call/usage sites.

You did the right thing there by introducing the accessor, which moves the
ifdef out of code that wants to query the member right? But you can still
leave it in the .c file if it is local (which it is).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
