Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E01AF8D0040
	for <linux-mm@kvack.org>; Sat,  2 Apr 2011 00:01:48 -0400 (EDT)
Received: by qwa26 with SMTP id 26so3459296qwa.14
        for <linux-mm@kvack.org>; Fri, 01 Apr 2011 21:01:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTik4q8N9vYUibSZfepUmhYoREo2dbH5NFZAHuOFb@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
 <AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
 <AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
 <alpine.LSU.2.00.1103182158200.18771@sister.anvils> <BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
 <AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
 <BANLkTim3x=1n+F7yD-euY0=RhmyXViUamg@mail.gmail.com> <AANLkTik4q8N9vYUibSZfepUmhYoREo2dbH5NFZAHuOFb@mail.gmail.com>
From: Hui Zhu <teawater@gmail.com>
Date: Sat, 2 Apr 2011 12:01:24 +0800
Message-ID: <BANLkTimTMTaUko92O2aFhabJSNrnsOuO4g@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

On Sat, Apr 2, 2011 at 00:35, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Apr 1, 2011 at 9:21 AM, Robert =C5=9Awi=C4=99cki <robert@swiecki.=
net> wrote:
>>
>> Is it possible to turn it off via config flags? Looking into
>> arch/x86/include/asm/bug.h it seems it's unconditional (as in "it
>> always manifests itself somehow") and I have
>> CONFIG_DEBUG_BUGVERBOSE=3Dy.
>
> Ok, if you have CONFIG_DEBUG_BUGVERBOSE then, you do have the bug-table.
>
> Maybe it's just kdb that is broken, and doesn't print it. I wouldn't
> be surprised. It's not the first time I've seen debugging features
> that just make debugging a mess.
>
>> Anything that could help you debugging this? Uploading kernel image
>> (unfortunately I've overwritten this one), dumping more kgdb data?
>
> So in this case kgdb just dropped the most important data on the floor.
>
> But if you have kdb active next time, print out the vma/old contents
> in that function that has the BUG() in it.
>
>> I must admit I'm not up-to-date with current linux kernel debugging
>> techniques. The kernel config is here:
>> http://alt.swiecki.net/linux_kernel/ise-test-2.6.38-kernel-config.txt
>>
>> For now I'll compile with -O0 -fno-inline (are you sure you'd like -Os?)

Hi Robert,

I am not sure you can success with build trunk with  -O0 -fno-inline.
I suggest you try the patch in
http://code.google.com/p/kgtp/downloads/detail?name=3Dco.patch.
It add a option in "Kernel hacking" called "Compile with almost no
optimization". It will make kernel be built without -O2. It support
x86_32, x86_64 and arm.

PS, maybe you can try kgtp (https://code.google.com/p/kgtp/)  debug your ke=
rnel.

Thanks,
Hui

>
> Oh, don't do that. -O0 makes the code totally unreadable (the compiler
> just does _stupid_ things, making the asm code look so horrible that
> you can't match it up against anything sane), and -fno-inline isn't
> worth the pain either.
>
> -Os is much better than those.
>
> But in this case, just getting the filename and line number would have
> made the thing moot anyway - without kdb it _should_ have said
> something clear like
>
> =C2=A0 kernel BUG at %s:%u!
>
> where %s:%u is the filename and line number.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0Linus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
