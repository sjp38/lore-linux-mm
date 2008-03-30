Received: by wf-out-1314.google.com with SMTP id 25so1406367wfc.11
        for <linux-mm@kvack.org>; Sun, 30 Mar 2008 13:23:12 -0700 (PDT)
Message-ID: <86802c440803301323q5c4bd4f4k1f9bdc1d6b1a0a7b@mail.gmail.com>
Date: Sun, 30 Mar 2008 13:23:12 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
In-Reply-To: <20080326073823.GD3442@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080324182122.GA28327@sgi.com> <87abknhzhd.fsf@basil.nowhere.org>
	 <20080325175657.GA6262@sgi.com> <20080326073823.GD3442@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jack Steiner <steiner@sgi.com>, Andi Kleen <andi@firstfloor.org>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 26, 2008 at 12:38 AM, Ingo Molnar <mingo@elte.hu> wrote:
>
>  * Jack Steiner <steiner@sgi.com> wrote:
>
>  > > > -        obj-y                            += genapic_64.o genapic_flat_64.o
>  > > > +        obj-y                            += genapic_64.o genapic_flat_64.o genx2apic_uv_x.o
>  > >
>  > > Definitely should be a CONFIG
>  >
>  > Not sure that I understand why. The overhead of UV is minimal & we
>  > want UV enabled in all distro kernels. OTOH, small embedded systems
>  > probably want to eliminate every last bit of unneeded code.
>  >
>  > Might make sense to have a config option. Thoughts????
>
>  i wouldnt mind having UV enabled by default (it can be a config option
>  but default-enabled on generic kernels so all distros will pick this hw
>  support up), but we definitely need the genapic unification before we
>  can add more features.

config option would be reasonable.
for x86_64
subarch already have X86_PC, X86_VSMP.
we have X86_UVSMP

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
