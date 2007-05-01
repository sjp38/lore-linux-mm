Message-ID: <46374724.7050907@dawes.za.net>
Date: Tue, 01 May 2007 15:56:52 +0200
From: Rogan Dawes <discard@dawes.za.net>
MIME-Version: 1.0
Subject: Re: pcmcia ioctl removal
References: <20070430162007.ad46e153.akpm@linux-foundation.org>	<20070501084623.GB14364@infradead.org>	<Pine.LNX.4.64.0705010514300.9162@localhost.localdomain>	<Pine.LNX.4.61.0705011202510.18504@yvahk01.tjqt.qr> <20070501110023.GY943@1wt.eu>
In-Reply-To: <20070501110023.GY943@1wt.eu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, linux-pcmcia@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Robert P. J. Day" <rpjday@mindspring.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Willy Tarreau wrote:
> On Tue, May 01, 2007 at 12:12:36PM +0200, Jan Engelhardt wrote:
>> On May 1 2007 05:16, Robert P. J. Day wrote:
>>> on the other hand, the features removal file contains the following:
>>>
>>> ...
>>> What:   PCMCIA control ioctl (needed for pcmcia-cs [cardmgr, cardctl])
>>> When:   November 2005
>>> ...
>>>
>>> in other words, the PCMCIA ioctl feature *has* been listed as obsolete
>>> for quite some time, and is already a *year and a half* overdue for
>>> removal.
>>>
>>> in short, it's annoying to take the position that stuff can't be
>>> deleted without warning, then turn around and be reluctant to remove
>>> stuff for which *more than ample warning* has already been given.
>>> doing that just makes a joke of the features removal file, and makes
>>> you wonder what its purpose is in the first place.
>>>
>>> a little consistency would be nice here, don't you think?
>> I think this could raise their attention...
>>
>> init/Makefile
>> obj-y += obsolete.o
>>
>> init/obsolete.c:
>> static __init int obsolete_init(void)
>> {
>> 	printk("\e[1;31m""
>>
>> The following stuff is gonna get removed \e[5;37m SOON: \e[0m
>> 	- cardmgr
>> 	- foobar
>> 	- bweebol
>>
>> ");
>> 	schedule_timeout(3 * HZ);
>> 	return;
>> }
>>
>> static __exit void obsolete_exit(void) {}
> 
> There's something I like here : the fact that all features are centralized
> and not hidden in the noise. Clearly we need some standard inside the kernel
> to manage obsolete code as well as we currently do by hand.
> 
> Willy

The difference between this function and the PCAP/TCPDUMP warning is 
that the warning only showed up when the obsolete functionality was 
actually used.

Maybe a mechanism to automatically increase the severity of reporting as 
the removal date approaches would be an idea? i.e. for each new kernel 
that you build leading up the the removal date, a severity is calculated 
based on the time until official removal, and then, depending on the 
severity, the message can be logged in various ways.

Rogan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
