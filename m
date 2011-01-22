Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB32D8D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 21:20:26 -0500 (EST)
Received: by iwn40 with SMTP id 40so2404104iwn.14
        for <linux-mm@kvack.org>; Fri, 21 Jan 2011 18:20:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110122021647.GR9506@random.random>
References: <20110120154935.GA1760@barrios-desktop>
	<20110120161436.GB21494@random.random>
	<AANLkTikHNcD3aOWKJdPtCqdJi9C34iLPxj5-L8=gqBFc@mail.gmail.com>
	<20110121175843.GA1534@barrios-desktop>
	<20110121181442.GK9506@random.random>
	<20110122005901.GA1590@barrios-desktop>
	<20110122010820.GP9506@random.random>
	<20110122021647.GR9506@random.random>
Date: Sat, 22 Jan 2011 11:20:25 +0900
Message-ID: <AANLkTinAA=+JtEZQbb15DSznH5hkUGiw=km93Qe1TZf2@mail.gmail.com>
Subject: Re: [BUG]thp: BUG at mm/huge_memory.c:1350
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jan 22, 2011 at 11:16 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Sat, Jan 22, 2011 at 02:08:20AM +0100, Andrea Arcangeli wrote:
>> Yeah x86 is not entirely broken, just some .config, and it's not
>
> Like in this case sometime when I say x86 I mean x86_32, for clarity
> x86_64 has never been affected by this, regardless of the .config.
>
>> common code bug (which is the most important thing!). I think it's a
>> bug in set_pmd_at when paravirt is set and PSA is off. If I'm right 4m
>> pages with PSA off should also work when disabling paravirt.
>
> You said PSA and I kept saying it but I think we both meant
> PAE. There's PSE and PAE, PSA is mix ;).

Yes. It was typo. :)

>
>> I'm just trying to reproduce...
>
> Reproduced and fix posted in the other mail with lkml on CC. Hope it
> works!

Will test and report the result.

>
> Thanks,
> Andrea
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
