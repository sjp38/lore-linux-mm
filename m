Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 924056B0253
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 13:54:59 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id l196so4378711itl.15
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:54:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r194sor7268itr.62.2017.10.12.10.54.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 10:54:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1710121202210.28556@nuc-kabylake>
References: <20171010121513.GC5445@yexl-desktop> <20171011023106.izaulhwjcoam55jt@treble>
 <20171011170120.7flnk6r77dords7a@treble> <alpine.DEB.2.20.1710121202210.28556@nuc-kabylake>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 12 Oct 2017 10:54:57 -0700
Message-ID: <CAADWXX-M2uftDuCyAS+UMKACC6d-B+Zb-DDNGO76yRS5wuigHw@mail.gmail.com>
Subject: Re: [lkp-robot] [x86/kconfig] 81d3871900: BUG:unable_to_handle_kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Oct 12, 2017 at 10:05 AM, Christopher Lameter <cl@linux.com> wrote:
> On Wed, 11 Oct 2017, Josh Poimboeuf wrote:
>
>> I failed to add the slab maintainers to CC on the last attempt.  Trying
>> again.
>
> Hmmm... Yea. SLOB is rarely used and tested. Good illustration of a simple
> allocator and the K&R mechanism that was used in the early kernels.

Should we finally just get rid of SLOB?

I'm not happy about the whole "three different allocators" crap. It's
been there for much too long, and I've tried to cut it down before.
People always protest, but three different allocators, one of which
gets basically no testing, is not good.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
