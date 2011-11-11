Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B7D6F6B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 03:38:25 -0500 (EST)
Received: by vws16 with SMTP id 16so4342729vws.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:38:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1320985863.21206.40.camel@pasglop>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
	<CAPQyPG7RrpV8DBV_Qcgr2at_r25_ngjy_84J2FqzRPGfA3PGDA@mail.gmail.com>
	<4EBC085D.3060107@jp.fujitsu.com>
	<1320959579.21206.24.camel@pasglop>
	<alpine.LSU.2.00.1111101723500.1239@sister.anvils>
	<1320985863.21206.40.camel@pasglop>
Date: Fri, 11 Nov 2011 16:38:22 +0800
Message-ID: <CAPQyPG4WHiEqX_tQ1WHMqEWmYUrB8Br7x5PTTtYOH+9D4FHt9A@mail.gmail.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, lethal@linux-sh.org, linux@arm.linux.org.uk

On Fri, Nov 11, 2011 at 12:31 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> On Thu, 2011-11-10 at 18:09 -0800, Hugh Dickins wrote:
>> It was in this mail below, when Andrew sent Linus the patch, and Linus
>> opposed my "argument" in support: that wasn't on lkml or linux-mm,
>> but I don't see that its privacy needs protecting.
>>
>> KOSAKI-san then sent instead a patch to correct some ints to longs,
>> which Linus did put in: but changing them to a new "vm_flags_t".
>>
>> He was, I think, hoping that one of us would change all the other uses
>> of unsigned long vm_flags to vm_flags_t; but in fact none of us has
>> stepped up yet - yeah, we're still sulking that we didn't get our
>> shiny new 64-bit vm_flags ;)
>>
>> I think Linus is not opposed to PowerPC and others defining a 64-bit
>> vm_flags_t if you need it, but wants not to bloat the x86_32 vma.
>>
>> I'm still wary of the contortions we go to in constraining flags,
>> and feel that the 32-bit case holds back the 64-bit, which would
>> not itself be bloated at all.
>>
>> The subject is likely to come up again, more pressingly, with page
>> flags.
>
> Right, tho the good first step is to convert everything to vm_flags_t so
> we can easily switch if we want to, even on a per-arch basis...
>
> Oh well, now all we need is a volunteer :-)

Maybe a "Kernel Common Resource Authority" is needed for all similar
requests, just like IANA for IP addresses... :)


Thanks,
Nai
>
> Cheers,
> Ben.
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
