Subject: Re: [PATCH 01/14] Per zone counter functionality
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060608210045.62129826.akpm@osdl.org>
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com>
	 <20060608230244.25121.76440.sendpatchset@schroedinger.engr.sgi.com>
	 <20060608210045.62129826.akpm@osdl.org>
Content-Type: text/plain
Date: Fri, 09 Jun 2006 11:22:13 +0200
Message-Id: <1149844934.20886.41.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Thu, 2006-06-08 at 21:00 -0700, Andrew Morton wrote:
> On Thu, 8 Jun 2006 16:02:44 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:

> > +#ifdef CONFIG_SMP
> > +void refresh_cpu_vm_stats(int);
> > +void refresh_vm_stats(void);
> > +#else
> > +static inline void refresh_cpu_vm_stats(int cpu) { };
> > +static inline void refresh_vm_stats(void) { };
> > +#endif
> 
> do {} while (0), please.  Always.  All other forms (afaik) have problems. 
> In this case,
> 
> 	if (something)
> 		refresh_vm_stats();
> 	else
> 		foo();
> 
> will not compile.

It surely will, 'static inline' does not make it less of a function.
Although the trailing ; is not needed in the function definition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
