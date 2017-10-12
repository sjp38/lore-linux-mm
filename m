Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE62B6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 14:48:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r202so6818335wmd.1
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 11:48:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 81si617943wmj.84.2017.10.12.11.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 11:48:46 -0700 (PDT)
Date: Thu, 12 Oct 2017 11:48:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [lkp-robot] [x86/kconfig] 81d3871900:
 BUG:unable_to_handle_kernel
Message-Id: <20171012114843.d74096014cb88eedbaa7ac70@linux-foundation.org>
In-Reply-To: <CAADWXX-M2uftDuCyAS+UMKACC6d-B+Zb-DDNGO76yRS5wuigHw@mail.gmail.com>
References: <20171010121513.GC5445@yexl-desktop>
	<20171011023106.izaulhwjcoam55jt@treble>
	<20171011170120.7flnk6r77dords7a@treble>
	<alpine.DEB.2.20.1710121202210.28556@nuc-kabylake>
	<CAADWXX-M2uftDuCyAS+UMKACC6d-B+Zb-DDNGO76yRS5wuigHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christopher Lameter <cl@linux.com>, Josh Poimboeuf <jpoimboe@redhat.com>, kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matt Mackall <mpm@selenic.com>

On Thu, 12 Oct 2017 10:54:57 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, Oct 12, 2017 at 10:05 AM, Christopher Lameter <cl@linux.com> wrote:
> > On Wed, 11 Oct 2017, Josh Poimboeuf wrote:
> >
> >> I failed to add the slab maintainers to CC on the last attempt.  Trying
> >> again.
> >
> > Hmmm... Yea. SLOB is rarely used and tested. Good illustration of a simple
> > allocator and the K&R mechanism that was used in the early kernels.
> 
> Should we finally just get rid of SLOB?
> 
> I'm not happy about the whole "three different allocators" crap. It's
> been there for much too long, and I've tried to cut it down before.
> People always protest, but three different allocators, one of which
> gets basically no testing, is not good.
> 

I am not aware of anyone using slob.  We could disable it in Kconfig
for a year, see what the feedback looks like.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
