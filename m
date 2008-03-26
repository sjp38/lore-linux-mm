Date: Wed, 26 Mar 2008 08:29:45 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080326072945.GC3442@elte.hu>
References: <20080324182122.GA28327@sgi.com> <87abknhzhd.fsf@basil.nowhere.org> <20080325175657.GA6262@sgi.com> <20080325180616.GX2170@one.firstfloor.org> <47E9B398.3080008@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47E9B398.3080008@goop.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andi Kleen <andi@firstfloor.org>, Jack Steiner <steiner@sgi.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Glauber de Oliveira Costa <glommer@gmail.com>
List-ID: <linux-mm.kvack.org>

* Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Andi Kleen wrote:
>> No instead of having lots of if (xyz_system) do_xyz_special()
>> go through smp_ops for the whole thing so that UV would just have a 
>> special smp_ops that has special implementions or wrappers. 
>> Oops I see smp_ops are currently only implemented
>> for 32bit. Ok do it only once smp_ops exist on 64bit too.   
>
> I think glommer has patches to unify smp stuff, which should include 
> smp_ops.

yep, x86.git/latest has all that work included.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
