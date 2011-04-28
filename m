Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4EFDC6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 02:34:19 -0400 (EDT)
Message-ID: <4DB90A66.3020805@kpanic.de>
Date: Thu, 28 Apr 2011 08:34:14 +0200
From: Stefan Assmann <sassmann@kpanic.de>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/3] support for broken memory modules (BadRAM)
References: <1303921007-1769-1-git-send-email-sassmann@kpanic.de> <1303921007-1769-3-git-send-email-sassmann@kpanic.de> <20110427211258.GQ16484@one.firstfloor.org>
In-Reply-To: <20110427211258.GQ16484@one.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, tony.luck@intel.com, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, akpm@linux-foundation.org, lwoodman@redhat.com, riel@redhat.com

On 27.04.2011 23:12, Andi Kleen wrote:
> On Wed, Apr 27, 2011 at 06:16:46PM +0200, Stefan Assmann wrote:
>> BadRAM is a mechanism to exclude memory addresses (pages) from being used by
>> the system. The addresses are given to the kernel via kernel command line.
>> This is useful for systems with defective RAM modules, especially if the RAM
>> modules cannot be replaced.
>>
>> command line parameter: badram=<addr>,<mask>[,...]
>>
>> Patterns for the command line parameter can be obtained by running Memtest86.
>> In Memtest86 press "c" for configuration, select "Error Report Mode" and
>> finally "BadRAM Patterns"
>>
>> This has already been done by Rick van Rein a long time ago but it never found
>> it's way into the kernel.
> 
> Looks good to me, except for the too verbose printks. Logging
> every page this way will be very noisy for larger areas.

You're right, logging every page marked would be too verbose. That's why
I wrapped that logging into pr_debug.
http://www.kernel.org/doc/local/pr_debug.txt
This way it shouldn't bother anybody but it still could be useful in the
case of debugging.
However I kept the printk in the case of early allocated pages. The user
should be notified of the attempt to mark a page that's already been
allocated by the kernel itself.

> 
> The mask will also only work for very simple memory interleaving
> setups, so I suspect it won't work for a lot of modern systems
> unless you go more fancy.
> 
> Longer term there should be also likely a better way to specify
> these pages than the kernel command line, e.g. the new persistent
> store on some systems.

I'd be happy to help improving and refining things for more fancy
scenarios after this is done.

Thanks for the feedback Andi.

  Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
