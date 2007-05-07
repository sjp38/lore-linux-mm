Date: Mon, 7 May 2007 12:01:07 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] removes MAX_ARG_PAGES
Message-ID: <20070507190107.GF19966@holomorphy.com>
References: <65dd6fd50705060151m78bb9b4fpcb941b16a8c4709e@mail.gmail.com> <617E1C2C70743745A92448908E030B2A01719390@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <617E1C2C70743745A92448908E030B2A01719390@scsmsx411.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ollie Wild <aaw@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

At some point in the past, Ollie Wild wrote:
>> We've tested the following architectures: i386, x86_64, um/i386,
>> parisc, and frv.  These are representative of the various scenarios
>> which this patch addresses, but other architecture teams should try it
>> out to make sure there aren't any unexpected gotchas.

On Mon, May 07, 2007 at 10:46:49AM -0700, Luck, Tony wrote:
> Doesn't build on ia64: complaints from arch/ia64/ia32/binfmt_elf.c
> (which #includes ../../../fs/binfmt_elf.c) ...
[...]
> Turning off CONFIG_IA32-SUPPORT, the kernel built, but oops'd during boot.
> My serial connection to my test machine is currently broken, so I didn't
> get a capture of the stack trace, sorry.

It needs to sweep 32-bit emulation code more generally.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
