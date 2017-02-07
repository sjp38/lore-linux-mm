Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C3B086B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 14:24:42 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m98so121259333iod.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 11:24:42 -0800 (PST)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id j130si12628469iof.9.2017.02.07.11.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 11:24:42 -0800 (PST)
Received: by mail-io0-x22f.google.com with SMTP id j13so98156860iod.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 11:24:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+QyJBtPKsfn40p5fUJT+sch8AEOmgM73Fmn4tFaLHAYA@mail.gmail.com>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <CAGXu5j+QyJBtPKsfn40p5fUJT+sch8AEOmgM73Fmn4tFaLHAYA@mail.gmail.com>
From: Thomas Garnier <thgarnie@google.com>
Date: Tue, 7 Feb 2017 11:24:41 -0800
Message-ID: <CAJcbSZFF7FdCaay_tEqUkZrmBfgsJbYnypyNDLdaEkL97HQmPw@mail.gmail.com>
Subject: Re: PCID review?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Feb 7, 2017 at 11:11 AM, Kees Cook <keescook@chromium.org> wrote:
> On Tue, Feb 7, 2017 at 10:56 AM, Andy Lutomirski <luto@kernel.org> wrote:
>> Quite a few people have expressed interest in enabling PCID on (x86)
>> Linux.  Here's the code:
>>
>> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/pcid
>>
>> The main hold-up is that the code needs to be reviewed very carefully.
>> It's quite subtle.  In particular, "x86/mm: Try to preserve old TLB
>> entries using PCID" ought to be looked at carefully to make sure the
>> locking is right, but there are plenty of other ways this this could
>> all break.
>>
>> Anyone want to take a look or maybe scare up some other reviewers?
>> (Kees, you seemed *really* excited about getting this in.)
>
> Yeah, I'd really like to build on it to gain SMAP emulation, though
> both implementing that and reviewing the existing series is outside my
> current skills (well, okay, you could add "Reviewed-by:"-me to the
> first 3 patches ;)). I don't know Intel guts well enough to
> meaningfully do anything on the others. :)
>
> I've added Thomas Garnier to CC, in case this is something he might be
> able to assist with.

It would be great to add but I have limited cycles and definitely
lacking knowledge on that front.

>
> Does this need benchmarking or other testing? Perhaps bring it to the
> kernel-hardening list for that?
>
> Also, what's needed to gain SMAP emulation?
>
> -Kees
>
> --
> Kees Cook
> Pixel Security



-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
