Message-Id: <200606091819.k59IJTlN027053@laptop11.inf.utfsm.cl>
Subject: Re: [PATCH 01/14] Per zone counter functionality 
In-Reply-To: Message from Peter Zijlstra <a.p.zijlstra@chello.nl>
   of "Fri, 09 Jun 2006 11:22:13 +0200." <1149844934.20886.41.camel@lappy>
Date: Fri, 09 Jun 2006 14:19:29 -0400
From: Horst von Brand <vonbrand@inf.utfsm.cl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

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

The trailing ';' is broken.
-- 
Dr. Horst H. von Brand                   User #22616 counter.li.org
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
