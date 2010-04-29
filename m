Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E13EE6B0203
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 14:54:02 -0400 (EDT)
Message-ID: <4BD9D5BE.4010000@redhat.com>
Date: Thu, 29 Apr 2010 21:53:50 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default> <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default> <4BD3377E.6010303@redhat.com> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com> <ce808441-fae6-4a33-8335-f7702740097a@default> <20100428055538.GA1730@ucw.cz>
In-Reply-To: <20100428055538.GA1730@ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/28/2010 08:55 AM, Pavel Machek wrote:
>
>> That's a reasonable analogy.  Frontswap serves nicely as an
>> emergency safety valve when a guest has given up (too) much of
>> its memory via ballooning but unexpectedly has an urgent need
>> that can't be serviced quickly enough by the balloon driver.
>>      
> wtf? So lets fix the ballooning driver instead?
>    

You can't have a negative balloon size.  The two models are not equivalent.

Balloon allows you to give up a page for which you have a struct page.  
Frontswap (and swap) allows you to gain a page for which you don't have 
a struct page, but you can't access it directly.  The similarity is that 
in both cases the host may want the guest to give up a page, but cannot 
force it.

> There's no reason it could not be as fast as frontswap, right?
> Actually I'd expect it to be faster -- it can deal with big chunks.
>    

There's no reason for swapping and ballooning to behave differently when 
swap backing storage is RAM (they probably do now since swap was tuned 
for disks, not flash, but that's a bug if it's true).

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
