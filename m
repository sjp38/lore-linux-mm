Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AE4E35F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:56:47 -0400 (EDT)
Message-ID: <4A24F5CB.30206@redhat.com>
Date: Tue, 02 Jun 2009 12:50:03 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Warn if we run out of swap space
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <4A23FF89.2060603@redhat.com> <20090601123503.2337a79b.akpm@linux-foundation.org> <4A242F94.9010704@redhat.com> <20090602091544.GC15756@elf.ucw.cz> <4A24EF07.6070708@redhat.com> <20090602093012.GA17132@elf.ucw.cz>
In-Reply-To: <20090602093012.GA17132@elf.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux-foundation.org, linux-mm@kvack.org, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:
> On Tue 2009-06-02 12:21:11, Avi Kivity wrote:
>   
>> Pavel Machek wrote:
>>     
>>> Ouch and please... don't stop useful printk() warnings just because
>>> some 'pie-in-the-sky future binary protocol'. That's what happened in
>>> ACPI land with battery critical, and it is also why I don't get
>>> battery warnings on some of my machines.
>>>   
>>>       
>> I don't oppose printk() on significant events (such as this) in addition  
>> to a proper programmatic interface.
>>     
>
> Good. So lets merge printk now, and someone can create proper
> programmatic interface? :-).
>
>   

No objection here.

> (Top can already display swap usage, so I guess interface is really
> there but needs to be polled which is ugly... but maybe workable for
> this use?)		

Don't say things like that where power people can hear you.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
