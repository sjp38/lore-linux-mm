Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1AB6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 15:29:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v6so1049274pfl.16
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 12:29:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v2sor4311824iod.224.2017.10.02.12.29.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 12:29:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170925194130.GV8421@gate.crashing.org>
References: <20170921093729.1080368AC1@po15668-vm-win7.idsi0.si.c-s.fr>
 <CAGXu5jJ54+bCcXaPK1ExsxtTDPHNn1+1gywb3TDbe-SEtt1zuQ@mail.gmail.com>
 <20170925073721.GM8421@gate.crashing.org> <063D6719AE5E284EB5DD2968C1650D6DD007F58B@AcuExch.aculab.com>
 <20170925194130.GV8421@gate.crashing.org>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 2 Oct 2017 12:29:45 -0700
Message-ID: <CAGXu5j+bj1NHmrrEmcwPavKubavLh1b01AyyJEFRvycg9FkLpg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix RODATA_TEST failure "rodata_test: test data was
 not read only"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Segher Boessenkool <segher@kernel.crashing.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: David Laight <David.Laight@aculab.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jinbum Park <jinb.park7@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Mon, Sep 25, 2017 at 12:41 PM, Segher Boessenkool
<segher@kernel.crashing.org> wrote:
> On Mon, Sep 25, 2017 at 04:01:55PM +0000, David Laight wrote:
>> From: Segher Boessenkool
>> > The compiler puts this item in .sdata, for 32-bit.  There is no .srodata,
>> > so if it wants to use a small data section, it must use .sdata .
>> >
>> > Non-external, non-referenced symbols are not put in .sdata, that is the
>> > difference you see with the "static".
>> >
>> > I don't think there is a bug here.  If you think there is, please open
>> > a GCC bug.
>>
>> The .sxxx sections are for 'small' data that can be accessed (typically)
>> using small offsets from a global register.
>> This means that all sections must be adjacent in the image.
>> So you can't really have readonly small data.
>>
>> My guess is that the linker script is putting .srodata in with .sdata.
>
> .srodata does not *exist* (in the ABI).

So, I still think this is a bug. The variable is marked const: this is
not a _suggestion_. :) If the compiler produces output where the
variable is writable, that's a bug.

I can't tell if this bug is related:
https://gcc.gnu.org/bugzilla/show_bug.cgi?id=9571

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
