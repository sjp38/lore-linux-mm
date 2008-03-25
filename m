Date: Tue, 25 Mar 2008 19:06:16 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080325180616.GX2170@one.firstfloor.org>
References: <20080324182122.GA28327@sgi.com> <87abknhzhd.fsf@basil.nowhere.org> <20080325175657.GA6262@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325175657.GA6262@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > This should be probably factored properly (didn't Jeremy have smp_ops 
> > for this some time ago) so that even the default case is a call.
> 
> By factored, do you means something like:
> 	is_uv_legacy_system()
> 	is_us_non_unique_apicid_system()
> 	...
> 
> Or maybe:
> 	is_uv_system_type(x)   # where x is UV_NON_UNIQUE_APIC, etc

No instead of having lots of if (xyz_system) do_xyz_special()
go through smp_ops for the whole thing so that UV would just have a 
special smp_ops that has special implementions or wrappers. 

Oops I see smp_ops are currently only implemented
for 32bit. Ok do it only once smp_ops exist on 64bit too. 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
