Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8E46B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 14:11:45 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id q20so122316954ioi.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 11:11:45 -0800 (PST)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id 96si12606673ioh.96.2017.02.07.11.11.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 11:11:44 -0800 (PST)
Received: by mail-io0-x233.google.com with SMTP id v96so98073597ioi.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 11:11:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 7 Feb 2017 11:11:43 -0800
Message-ID: <CAGXu5j+QyJBtPKsfn40p5fUJT+sch8AEOmgM73Fmn4tFaLHAYA@mail.gmail.com>
Subject: Re: PCID review?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Thomas Garnier <thgarnie@google.com>

On Tue, Feb 7, 2017 at 10:56 AM, Andy Lutomirski <luto@kernel.org> wrote:
> Quite a few people have expressed interest in enabling PCID on (x86)
> Linux.  Here's the code:
>
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/pcid
>
> The main hold-up is that the code needs to be reviewed very carefully.
> It's quite subtle.  In particular, "x86/mm: Try to preserve old TLB
> entries using PCID" ought to be looked at carefully to make sure the
> locking is right, but there are plenty of other ways this this could
> all break.
>
> Anyone want to take a look or maybe scare up some other reviewers?
> (Kees, you seemed *really* excited about getting this in.)

Yeah, I'd really like to build on it to gain SMAP emulation, though
both implementing that and reviewing the existing series is outside my
current skills (well, okay, you could add "Reviewed-by:"-me to the
first 3 patches ;)). I don't know Intel guts well enough to
meaningfully do anything on the others. :)

I've added Thomas Garnier to CC, in case this is something he might be
able to assist with.

Does this need benchmarking or other testing? Perhaps bring it to the
kernel-hardening list for that?

Also, what's needed to gain SMAP emulation?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
