From: Boris Petkov <bp@alien8.de>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover from machine checks
Date: Sun, 27 Dec 2015 14:17:37 +0100
Message-ID: <6c0b3214-f120-47ee-b7fe-677b4f27f039@email.android.com>
References: <20151224214632.GF4128@pd.tnic> <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com> <20151225114937.GA862@pd.tnic> <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com> <20151226103252.GA21988@pd.tnic> <CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com> <CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com> <CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com> <CALCETrU3OCVJoBWXcdmy-9Rr3d3rJ93606K1vC3V9zfT2bQc2g@mail.gmail.com> <CA+8MBbJcw8dRW3DBYW-EhcOiGYFCm7HUxwG-df67wJCOqMpz0A@mail.gmail.com> <20151227100919.GA19398@nazgul.tnic> <CALCETrUcSB8ix0HSPyTwXT46gMAE2iGVZ8V1kEbkQVxVqrQFiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUcSB8ix0HSPyTwXT46gMAE2iGVZ8V1kEbkQVxVqrQFiQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Cc: Tony Luck <tony.luck@gmail.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Andy Lutomirski <luto@amacapital.net> wrote:
>You certainly can, but it doesn't scale well to multiple users of
>similar mechanisms.  It also prevents you from using the same
>mechanism in anything that could be inlined, which is IMO kind of
>unfortunate.

Well, but the bit 31 game doesn't make it any better than the bit 63 fun IMO. Should the exception table entry maybe grow a u32 flags instead? 



-- 
Sent from a small device: formatting sux and brevity is inevitable. 
