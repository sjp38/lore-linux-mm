Date: Tue, 25 Mar 2008 20:09:30 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 6/8] x86_64: Define the macros and tables for the basic
	UV infrastructure.
Message-ID: <20080326000930.GB18701@infradead.org>
References: <20080324182118.GA21758@sgi.com> <87ej9zi05c.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ej9zi05c.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Jack Steiner <steiner@sgi.com>, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 11:11:11AM +0100, Andi Kleen wrote:
> Not sure what physical mode is.
> 
> > +#ifdef __BIOS__
> > +#define UV_ADDR(x)		((unsigned long *)(x))
> > +#else
> > +#define UV_ADDR(x)		((unsigned long *)__va(x))
> > +#endif
> 
> But it it would be cleaner if your BIOS just supplied a suitable __va()
> and then you remove these macros.

the bios should just have headers of it's own instead of placing this
burden on kernel code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
