From: Borislav Petkov <bp@alien8.de>
Subject: Re: several messages
Date: Fri, 29 Jan 2016 14:21:14 +0100
Message-ID: <20160129132114.GF10187@pd.tnic>
References: <cover.1453746505.git.luto@kernel.org>
 <20160125185706.GA28416@gmail.com>
 <alpine.DEB.2.11.1601271108230.3886@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1601271108230.3886@nanos>
Sender: linux-kernel-owner@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, x86@kernel.org, linux-kernel@vger.kernel.org, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>
List-Id: linux-mm.kvack.org

On Wed, Jan 27, 2016 at 11:09:04AM +0100, Thomas Gleixner wrote:
> On Mon, 25 Jan 2016, Andy Lutomirski wrote:
> > This is a straightforward speedup on Ivy Bridge and newer, IIRC.
> > (I tested on Skylake.  INVPCID is not available on Sandy Bridge.
> > I don't have Ivy Bridge, Haswell or Broadwell to test on, so I
> > could be wrong as to when the feature was introduced.)
>
> Haswell and Broadwell have it. No idea about ivy bridge.

I have an IVB model 58. It doesn't have it:

CPUID_0x00000007: EAX=0x00000000, EBX=0x00000281, ECX=0x00000000, EDX=0x00000000

INVPCID should be EBX[10].

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
