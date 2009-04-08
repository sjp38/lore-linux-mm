Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E9C205F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 03:38:41 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so2811310wfa.11
        for <linux-mm@kvack.org>; Wed, 08 Apr 2009 00:39:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090408065121.GI17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
	 <20090407150959.C099D1D046E@basil.firstfloor.org>
	 <28c262360904071621j5bdd8e33u1fbd8534d177a941@mail.gmail.com>
	 <20090408065121.GI17934@one.firstfloor.org>
Date: Wed, 8 Apr 2009 16:39:17 +0900
Message-ID: <28c262360904080039l65c381edn106484c88f1c5819@mail.gmail.com>
Subject: Re: [PATCH] [3/16] POISON: Handle poisoned pages in page free
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 8, 2009 at 3:51 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Page may have been marked bad before pr=
ocess is freeing it.
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Make sure it is not put back into the f=
ree page lists.
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 if (PagePoison(page)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* check more flags=
 here... */
>>
>> How about adding WARNING with some information(ex, pfn, flags..).
>
> The memory_failure() code is already quite chatty. Don't think more
> noise is needed currently.

Sure.

> Or are you worrying about the case where a page gets corrupted
> by software and suddenly has Poison bits set? (e.g. 0xff everywhere).
> That would deserve a printk, but I'm not sure how to reliably test for
> that. After all a lot of flag combinations are valid.

I misunderstood your code.
That's because you add the code in bad_page.

As you commented, your intention was to prevent bad page from returning bud=
dy.
Is right ?
If it is right, how about adding prevention code to free_pages_check ?
Now, bad_page is for showing the information that why it is bad page
I don't like emergency exit in bad_page.

> -Andi
>
> --
> ak@linux.intel.com -- Speaking for myself only.
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
