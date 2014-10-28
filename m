Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3A273900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 10:00:28 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id y10so914693wgg.27
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 07:00:27 -0700 (PDT)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id q8si14542426wiv.49.2014.10.28.07.00.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 07:00:26 -0700 (PDT)
Received: by mail-wg0-f43.google.com with SMTP id n12so906294wgh.26
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 07:00:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141028133131.GA1445@sirus.conectiva>
References: <CAGqmi77uR2Nems6fE_XM1t3a06OwuqJP-0yOMOQh7KH13vzdzw@mail.gmail.com>
 <20141025213201.005762f9.akpm@linux-foundation.org> <20141028133131.GA1445@sirus.conectiva>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Tue, 28 Oct 2014 16:59:45 +0300
Message-ID: <CAGqmi76b0oUMAsAvBt=PwaxF5JZXcckSdWe2=bL_pXaiUFFCXQ@mail.gmail.com>
Subject: Re: UKSM: What's maintainers think about it?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marco A Benatto <marco.benatto@mandriva.com.br>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

2014-10-28 16:31 GMT+03:00 Marco A Benatto <marco.benatto@mandriva.com.br>:
> Hi All,
>
> I'm not mantainer at all, but I've being using UKSM for a long time and remember
> to port it to 3.16 family once.
> UKSM seems good and stable and, at least for me, doesn't raised any errors.
> AFAIK the only limitation I know (maybe I has been fixed already) it isn't able
> to work together with zram stuff due to some race-conditions.
>
> Cheers,
>
> Marco A Benatto
> Mandriva OEM Developer
>

http://kerneldedup.org/forum/forum.php?mod=viewthread&tid=106
As i did find, uksm not conflicting with zram (or zswap - on my system).

---
Offtop:
Why i open up question about UKSM?

May be we (as community, who want to help) can split out UKSM in
"several patches" in independent git repo. For allowing maintainers to
review this.

Is it morally correct?

UKSM code licensed under GPL and as i think we can feel free for port
and adopt code (with indicating the author)

Please, fix me if i mistake or miss something.
This is just stream of my thoughts %_%
---

> On Sat, Oct 25, 2014 at 09:32:01PM -0700, Andrew Morton wrote:
>> On Sat, 25 Oct 2014 22:25:56 +0300 Timofey Titovets <nefelim4ag@gmail.com> wrote:
>>
>> > Good time of day, people.
>> > I try to find 'mm' subsystem specific people and lists, but list
>> > linux-mm looks dead and mail archive look like deprecated.
>> > If i must to sent this message to another list or add CC people, let me know.
>>
>> linux-mm@kvack.org is alive and well.

So cool, thanks for adding 'mm' to CC.

>> > If questions are already asked (i can't find activity before), feel
>> > free to kick me.
>> >
>> > The main questions:
>> > 1. Somebody test it? I see many reviews about it.
>> > I already port it to latest linux-next-git kernel and its work without issues.
>> > http://pastebin.com/6FMuKagS
>> > (if it matter, i can describe use cases and results, if somebody ask it)
>> >
>> > 2. Developers of UKSM already tried to merge it? Somebody talked with uksm devs?
>> > offtop: now i try to communicate with dev's on kerneldedup.org forum,
>> > but i have problems with email verification and wait admin
>> > registration approval.
>> > (i already sent questions to
>> > http://kerneldedup.org/forum/home.php?mod=space&username=xianai ,
>> > because him looks like team leader)
>> >
>> > 3. I just want collect feedbacks from linux maintainers team, if you
>> > decide what UKSM not needed in kernel, all other comments (as i
>> > understand) not matter.
>> >
>> > Like KSM, but better.
>> > UKSM - Ultra Kernel Samepage Merging
>> > http://kerneldedup.org/en/projects/uksm/introduction/
>>
>> It's the first I've heard of it.  No, as far as I know there has been
>> no attempt to upstream UKSM.
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
