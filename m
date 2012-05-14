Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id BB4276B0081
	for <linux-mm@kvack.org>; Sun, 13 May 2012 21:51:30 -0400 (EDT)
Message-ID: <4FB06537.4070205@kernel.org>
Date: Mon, 14 May 2012 10:51:51 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: raise MemFree by reverting percpu_pagelist_fraction
 to 0
References: <alpine.LSU.2.00.1205110054520.2801@eggly.anvils> <CA+1xoqcChazS=TRt6-7GjJAzQNFLFXmO623rWwjRkdD5x3k=iw@mail.gmail.com> <4FACD00D.4060003@kernel.org> <alpine.LSU.2.00.1205110656540.5839@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1205110656540.5839@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Hugh,

On 05/11/2012 11:10 PM, Hugh Dickins wrote:

> On Fri, 11 May 2012, Minchan Kim wrote:
>> On 05/11/2012 05:30 PM, Sasha Levin wrote:
>>
>>>> Commit 93278814d359 "mm: fix division by 0 in percpu_pagelist_fraction()"
>>>> mistakenly initialized percpu_pagelist_fraction to the sysctl's minimum 8,
>>>> which leaves 1/8th of memory on percpu lists (on each cpu??); but most of
>>>> us expect it to be left unset at 0 (and it's not then used as a divisor).
>>>
>>> I'm a bit confused about this, does it mean that once you set
>>> percpu_pagelist_fraction to a value above the minimum, you can no
>>> longer set it back to being 0?
>>
>>
>> Unfortunately, Yes. :(
>> It's rather awkward and need fix.
> 
> It's inelegant, but does that actually need a fix?  Has anybody asked
> for that option in the six years of percpu_pagelist_fraction?


I don't have heard about it but thing we can't reset to 0 again once we set some number to above 8 is
very strange. Sometime, someone may raise the value on /proc/sys/vm/percpu_pagelist_fraction to test it
and realized function of the knob so he want to reset it to 0 default value, again. But he couldn't.
It's very strange. :( 

> 
> Does setting percpu_pagelist_fraction to some large number perhaps
> approximate to the default behaviour of percpu_pagelist_fraction 0?


Yes. But it's not intuitive. 

> 
> I don't care very much either way - just don't want this discussion
> to divert from applying last night's fix to the default behaviour
> that most people expect.


Of course. 

It's totally from my careless review. 
Actually, I didn't find to change default value to 8 when I review the patch.
I just focused on proc_dointvec_minmax's err return value.


Shame on me. :(
Thanks for spot it.

> 
> Hugh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
