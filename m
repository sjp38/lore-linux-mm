Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E81F6B026D
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 16:17:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l5so6834936oib.0
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 13:17:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k22sor702000otb.94.2017.10.13.13.17.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 13:17:46 -0700 (PDT)
MIME-Version: 1.0
Reply-To: noloader@gmail.com
In-Reply-To: <CA+55aFyvK+proOBKfc41qSH8hoPU+mBiT0=hLhbt_ZQv4N82iA@mail.gmail.com>
References: <20171010121513.GC5445@yexl-desktop> <20171011023106.izaulhwjcoam55jt@treble>
 <20171011170120.7flnk6r77dords7a@treble> <alpine.DEB.2.20.1710121202210.28556@nuc-kabylake>
 <20171013044521.662ck56gkwaw3xog@treble> <9a1c3232-86e3-7301-23f8-50116abf37d3@virtuozzo.com>
 <CA+55aFyvK+proOBKfc41qSH8hoPU+mBiT0=hLhbt_ZQv4N82iA@mail.gmail.com>
From: Jeffrey Walton <noloader@gmail.com>
Date: Fri, 13 Oct 2017 16:17:45 -0400
Message-ID: <CAH8yC8=vqE_1xCmmrb_TQoVayL+rGEObpg6degbVYZuXQ1OU3w@mail.gmail.com>
Subject: Re: [lkp-robot] [x86/kconfig] 81d3871900: BUG:unable_to_handle_kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Christopher Lameter <cl@linux.com>, kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, linux-mm <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Megha Dey <megha.dey@linux.intel.com>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>

On Fri, Oct 13, 2017 at 3:09 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Oct 13, 2017 at 6:56 AM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>>
>> This could be fixed by s/vmovdqa/vmovdqu change like bellow, but maybe the right fix
>> would be to align the data properly?
>
> I suspect anything that has the SHA extensions should also do
> unaligned loads efficiently. The whole "aligned only" model is broken.
> It's just doing two loads from the state pointer, there's likely no
> point in trying to align it.

+1, good engineering.

AVX2 requires 32-byte buffer alignment in some places. It is trickier
than this use case because __BIGGEST_ALIGNMENT__ doubled, but a lot of
code still assumes 16-bytes.

Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
