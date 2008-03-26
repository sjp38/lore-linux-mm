Date: Wed, 26 Mar 2008 08:38:23 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080326073823.GD3442@elte.hu>
References: <20080324182122.GA28327@sgi.com> <87abknhzhd.fsf@basil.nowhere.org> <20080325175657.GA6262@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325175657.GA6262@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> > > -        obj-y				+= genapic_64.o genapic_flat_64.o
> > > +        obj-y				+= genapic_64.o genapic_flat_64.o genx2apic_uv_x.o
> > 
> > Definitely should be a CONFIG
> 
> Not sure that I understand why. The overhead of UV is minimal & we 
> want UV enabled in all distro kernels. OTOH, small embedded systems 
> probably want to eliminate every last bit of unneeded code.
> 
> Might make sense to have a config option. Thoughts????

i wouldnt mind having UV enabled by default (it can be a config option 
but default-enabled on generic kernels so all distros will pick this hw 
support up), but we definitely need the genapic unification before we 
can add more features.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
