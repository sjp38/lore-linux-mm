Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8B6445F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:25:58 -0400 (EDT)
Message-ID: <4A24EE8E.1040908@redhat.com>
Date: Tue, 02 Jun 2009 12:19:10 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Warn if we run out of swap space
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <4A23FF89.2060603@redhat.com> <20090601123503.2337a79b.akpm@linux-foundation.org> <4A242F94.9010704@redhat.com> <20090602091413.GB15756@elf.ucw.cz>
In-Reply-To: <20090602091413.GB15756@elf.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux-foundation.org, linux-mm@kvack.org, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:
>>> Perhaps careful use of faciliy levels would suffice for a), but I
>>> expect that some new tagging scheme would be more practical.
>>>   
>>>       
>> I thought dmesg was an unreliable channel which can overflow.  It's also  
>> prone to attacks by spell checkers.
>>     
>
> Well, I believe that any used-enough channecl will eventually
> overflow. So dmesg still looks like the best we can do.
>   

No.  Two examples:

- eventfd won't overflow (but doesn't carry a lot of data)
- a channel which signals overflow reliably and allows the user to query 
state can recover from overflow.

>> I prefer reliable binary interfaces to shell explorable text interfaces  
>> as I think any feature worth having is much more useful controlled by an  
>> application rather than a bored sysadmin.
>>     
>
> You are free to parse syslog. In fact, I guess some tags could be
> added for messages where userland reaction is expected...

Why create a piece of text, hide it in a bunch of unrelated pieces of 
text, then try to extract it?

I want straightforward interfaces.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
