Message-ID: <46A8E592.2070209@gmx.net>
Date: Thu, 26 Jul 2007 20:18:58 +0200
From: Michael Kerrisk <mtk-manpages@gmx.net>
MIME-Version: 1.0
Subject: Re: mbind.2 man page patch
References: <1180467234.5067.52.camel@localhost>	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>	 <200705292216.31102.ak@suse.de> <1180541849.5850.30.camel@localhost>	 <20070531082016.19080@gmx.net> <1180732544.5278.158.camel@localhost>	 <46A44B8D.2040200@gmx.net> <1185200768.5074.10.camel@localhost>	 <46A8D787.4090202@gmx.net> <1185473161.7653.20.camel@localhost>
In-Reply-To: <1185473161.7653.20.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: ak@suse.de, clameter@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org, Samuel Thibault <samuel.thibault@ens-lyon.org>
List-ID: <linux-mm.kvack.org>


Lee Schermerhorn wrote:
> On Thu, 2007-07-26 at 19:19 +0200, Michael Kerrisk wrote:
>> [...]
>>>> +If the specified memory range includes a memory mapped file mapped using
>>>> +.BR mmap (2)
>>>> +with the
>>>> +.B MAP_SHARED
>>>> +flag, the specified policy will be ignored for all page allocations
>>>> +in this range.
>>>> +.\" FIXME Lee / Andi: can you clarify/confirm "the specified policy
>>>> +.\" will be ignored for all page allocations in this range".
>>>> +.\" That text seems to be saying that if the memory range contains
>>>> +.\" (say) some mappings that are allocated with MAP_SHARED
>>>> +.\" and others allocated with MAP_PRIVATE, then the policy
>>>> +.\" will be ignored for all of the mappings, including even
>>>> +.\" the MAP_PRIVATE mappings.  Right?  I just want to be
>>>> +.\" sure that that is what the text is meaning.
>>> I can see from the wording how you might think this.  However, policy
>>> will only be ignored for the SHARED mappings.  
>> So is a better wording something like:
>>
>>     The specified policy will be ignored for any MAP_SHARED
>>     file mappings in the specified memory range.
>>
> 
> Wish I'd written that ;-)

It's just like code.  Simpler is usually better ;0-).

> Seriously, that is correct.

Good.

Cheers,

Michael

-- 
Michael Kerrisk
maintainer of Linux man pages Sections 2, 3, 4, 5, and 7

Want to help with man page maintenance?  Grab the latest tarball at
http://www.kernel.org/pub/linux/docs/manpages/
read the HOWTOHELP file and grep the source files for 'FIXME'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
