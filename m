From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Date: Sun, 27 Dec 2015 11:09:19 +0100
Message-ID: <20151227100919.GA19398@nazgul.tnic>
References: <20151224214632.GF4128@pd.tnic>
 <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
 <20151225114937.GA862@pd.tnic>
 <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
 <20151226103252.GA21988@pd.tnic>
 <CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com>
 <CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com>
 <CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com>
 <CALCETrU3OCVJoBWXcdmy-9Rr3d3rJ93606K1vC3V9zfT2bQc2g@mail.gmail.com>
 <CA+8MBbJcw8dRW3DBYW-EhcOiGYFCm7HUxwG-df67wJCOqMpz0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+8MBbJcw8dRW3DBYW-EhcOiGYFCm7HUxwG-df67wJCOqMpz0A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tony Luck <tony.luck@gmail.com>, Andy Lutomirski <luto@amacapital.net>
Cc: linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Sat, Dec 26, 2015 at 10:57:26PM -0800, Tony Luck wrote:
> ... will get the right value.  Maybe this would still work out
> if the fixup is a 31-bit value plus a flag, but the external
> tool thinks it is a 32-bit value?  I'd have to ponder that.

I still fail to see why do we need to make it so complicated and can't
do something like:


fixup_exception:
	...

#ifdef CONFIG_MCE_KERNEL_RECOVERY
		if (regs->ip >= (unsigned long)__mcsafe_copy &&
		    regs->ip <= (unsigned long)__mcsafe_copy_end)
			run_special_handler();
#endif

and that special handler does all the stuff we want. And we pass
X86_TRAP* etc through fixup_exception along with whatever else we
need from the trap handler...

Hmmm?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
