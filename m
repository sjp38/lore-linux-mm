Date: Fri, 9 Jun 2006 02:29:05 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 01/14] Per zone counter functionality
Message-Id: <20060609022905.fde74037.akpm@osdl.org>
In-Reply-To: <1149844934.20886.41.camel@lappy>
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com>
	<20060608230244.25121.76440.sendpatchset@schroedinger.engr.sgi.com>
	<20060608210045.62129826.akpm@osdl.org>
	<1149844934.20886.41.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Fri, 09 Jun 2006 11:22:13 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Thu, 2006-06-08 at 21:00 -0700, Andrew Morton wrote:
> > On Thu, 8 Jun 2006 16:02:44 -0700 (PDT)
> > Christoph Lameter <clameter@sgi.com> wrote:
> 
> > > +#ifdef CONFIG_SMP
> > > +void refresh_cpu_vm_stats(int);
> > > +void refresh_vm_stats(void);
> > > +#else
> > > +static inline void refresh_cpu_vm_stats(int cpu) { };
> > > +static inline void refresh_vm_stats(void) { };
> > > +#endif
> > 
> > do {} while (0), please.  Always.  All other forms (afaik) have problems. 
> > In this case,
> > 
> > 	if (something)
> > 		refresh_vm_stats();
> > 	else
> > 		foo();
> > 
> > will not compile.
> 
> It surely will, 'static inline' does not make it less of a function.
> Although the trailing ; is not needed in the function definition.

doh, I read it as a #define.  Ignore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
