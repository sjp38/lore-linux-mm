Subject: Re: Large stack usage in fs code (especially for PPC64)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20081117133137.616cf287.akpm@linux-foundation.org>
References: <alpine.DEB.1.10.0811171508300.8722@gandalf.stny.rr.com>
	 <20081117130856.92e41cd3.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.0811171320330.18283@nehalem.linux-foundation.org>
	 <20081117133137.616cf287.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 18 Nov 2008 10:17:04 +1100
Message-Id: <1226963824.7178.255.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, rostedt@goodmis.org, linux-kernel@vger.kernel.org, paulus@samba.org, linuxppc-dev@ozlabs.org, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I'd have thought so, but I'm sure we're about to hear how important an
> optimisation the smaller stacks are ;)

Not sure, I tend to agree that it would make sense to bump our stack to
64K on 64K pages, it's not like we are saving anything and we are
probably adding overhead in alloc/dealloc. I'll see what Paul thinks
here.

> Yup.  That being said, the younger me did assert that "this is a neater
> implementation anyway".  If we can implement those loops without
> needing those on-stack temporary arrays then things probably are better
> overall.

Amen.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
