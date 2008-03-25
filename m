Date: Tue, 25 Mar 2008 11:19:57 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [RFC 6/8] x86_64: Define the macros and tables for the basic UV infrastructure.
Message-ID: <20080325161957.GA1884@sgi.com>
References: <20080324182118.GA21758@sgi.com> <87ej9zi05c.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ej9zi05c.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 11:11:11AM +0100, Andi Kleen wrote:
> Jack Steiner <steiner@sgi.com> writes:
> 
> > Define the macros and tables for the basic UV infrastructure.
> > 
> > 
> > (NOTE: a work-in-progress. Pieces missing....)
> 
> Does the kernel really need all this information? You just want
> to address the UV-APIC right? I suspect you could use a much stripped
> down file.

Most of the macros will never be used by generic kernel code, but we
have UV-specific drivers that will use the information (GRU, XPC and
XPMEM drivers). All of these are getting very close to being ready to
be pushed upstream.

> 
> > +DECLARE_PER_CPU(struct uv_hub_info_s, __uv_hub_info);
> > +#define uv_hub_info 		(&__get_cpu_var(__uv_hub_info))
> > +#define uv_cpu_hub_info(cpu)	(&per_cpu(__uv_hub_info, cpu))
> > +
> > +/* This header file is used in BIOS code that runs in physical mode */
> 
> Not sure what physical mode is.

Me either :-)    I fixed the comment
	"... BIOS code that runs with virtual == physical"

However, then I read the rest of your comments & will take the approach
of defining __va() in the BIOS code. That eliminates the need for
the macro.

> 
> > +#ifdef __BIOS__
> > +#define UV_ADDR(x)		((unsigned long *)(x))
> > +#else
> > +#define UV_ADDR(x)		((unsigned long *)__va(x))
> > +#endif
> 
> But it it would be cleaner if your BIOS just supplied a suitable __va()
> and then you remove these macros.
> 
> -Andi

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
