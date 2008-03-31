Date: Mon, 31 Mar 2008 14:52:13 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080331125213.GF29105@one.firstfloor.org>
References: <87abknhzhd.fsf@basil.nowhere.org> <20080325175657.GA6262@sgi.com> <20080326073823.GD3442@elte.hu> <86802c440803301323q5c4bd4f4k1f9bdc1d6b1a0a7b@mail.gmail.com> <20080330210356.GA13383@sgi.com> <20080330211848.GA29105@one.firstfloor.org> <86802c440803301629g6d1b896o27e12ef3c84ded2c@mail.gmail.com> <20080331021821.GC20619@sgi.com> <86802c440803301920o47335876yac12a5a09d1a8cc9@mail.gmail.com> <20080331123338.GA14636@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080331123338.GA14636@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, Jack Steiner <steiner@sgi.com>, Andi Kleen <andi@firstfloor.org>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>  - mach-voyager: obsolete.

You just have to convince James @)

> 
>  - mach-es7000: on the way out - latest ES7000's are generic.

That would mean dropping support for prev-gen es7000 which are not that
old actually (only a few years). But I think with a little effort the 
old es7000 code could be fit into the generic architecture. It is not
that far away from a normal PC.

> 
>  - mach-rdc321x: it's being de-sub-architectured. It's about one patch 
>                  away from becoming a non-subarch.

mach-numaq (not in arch, but spread out all over the port) 
	I hear there are only a one or two machines running left.
	Unfortunately they are in test.kernel.org, but hopefully
	they will die soon.
	NUMAQ has quite a lot of ugly ifdefs and special cases that would be 
	great to eliminate

mach-bigsmp/mach-summit (also in asm only)
	obsolete, should be deprecated for mach-generic
	(just generic currently pulls in code from them)
	A good first step would be to just disable the separate CONFIG
	options and only allow using them through generic.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
