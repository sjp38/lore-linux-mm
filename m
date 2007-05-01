Message-ID: <46372D5D.1090702@muenning.com>
Date: Tue, 01 May 2007 14:06:53 +0200
From: =?ISO-8859-1?Q?Konstantin_M=FCnning?= <konstantin@muenning.com>
MIME-Version: 1.0
Subject: Re: pcmcia ioctl removal
References: <20070430162007.ad46e153.akpm@linux-foundation.org>	<20070501084623.GB14364@infradead.org>	<Pine.LNX.4.64.0705010514300.9162@localhost.localdomain>	<Pine.LNX.4.61.0705011202510.18504@yvahk01.tjqt.qr> <20070501110023.GY943@1wt.eu>
In-Reply-To: <20070501110023.GY943@1wt.eu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
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

What about something like the tainted flag which status can be displayed
 easily? And even better when a list of the used obsolete features can
be displayed as well on request? This way you don't need to search the
logs. A standardized obsolete function like the one above could do all
the job.

Just my 2 cents.
-- 
Konstantin Munning

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
