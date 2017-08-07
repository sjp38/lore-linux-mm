Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 205356B02F4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:12:50 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id v68so982908oia.14
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:12:50 -0700 (PDT)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id k129si4976162oih.103.2017.08.07.12.12.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:12:49 -0700 (PDT)
Received: by mail-io0-x22f.google.com with SMTP id m88so5957911iod.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:12:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN=P9pgcuXUk=+TvFC83UT7xT66=X2ouvEEWxzVVeM2mC=Tk=g@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
 <1502131739.1803.12.camel@gmail.com> <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
 <CAN=P9pj0TSbwTogLAJrm=yszq+86X0EmXNK-0Oq9f7wQCkQRjA@mail.gmail.com>
 <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com> <CAN=P9pgcuXUk=+TvFC83UT7xT66=X2ouvEEWxzVVeM2mC=Tk=g@mail.gmail.com>
From: Kees Cook <keescook@google.com>
Date: Mon, 7 Aug 2017 12:12:48 -0700
Message-ID: <CAGXu5jJNW5PYacSNrGGnyAxnv4cRuhbo+P9myHP9kcV7hMzhkA@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kostya Serebryany <kcc@google.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

On Mon, Aug 7, 2017 at 12:05 PM, Kostya Serebryany <kcc@google.com> wrote:
>
>
> On Mon, Aug 7, 2017 at 11:59 AM, Kees Cook <keescook@google.com> wrote:
>>
>> On Mon, Aug 7, 2017 at 11:56 AM, Kostya Serebryany <kcc@google.com> wrote:
>> > Is it possible to implement some userspace<=>kernel interface that will
>> > allow applications (sanitizers)
>> > to request *fixed* address ranges from the kernel at startup (so that
>> > the
>> > kernel couldn't refuse)?
>>
>> Wouldn't building non-PIE accomplish this?
>
>
> Well, many asan users do need PIE.
> Then, non-PIE only applies to the main executable, all DSOs are still
> PIC and the old change that moved DSOs from 0x7fff to 0x5555 caused us quite
> a bit of trouble too, even w/o PIE

Hm? You can build non-PIE executables leaving all the DSOs PIC.

If what you want is to entirely disable userspace ASLR under *San, you
can just set the ADDR_NO_RANDOMIZE personality flag.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
