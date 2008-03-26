Message-ID: <47E9B398.3080008@goop.org>
Date: Tue, 25 Mar 2008 19:23:20 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
References: <20080324182122.GA28327@sgi.com> <87abknhzhd.fsf@basil.nowhere.org> <20080325175657.GA6262@sgi.com> <20080325180616.GX2170@one.firstfloor.org>
In-Reply-To: <20080325180616.GX2170@one.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Jack Steiner <steiner@sgi.com>, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Glauber de Oliveira Costa <glommer@gmail.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> No instead of having lots of if (xyz_system) do_xyz_special()
> go through smp_ops for the whole thing so that UV would just have a 
> special smp_ops that has special implementions or wrappers. 
>
> Oops I see smp_ops are currently only implemented
> for 32bit. Ok do it only once smp_ops exist on 64bit too. 
>   

I think glommer has patches to unify smp stuff, which should include 
smp_ops.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
