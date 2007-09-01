Date: Sat, 1 Sep 2007 09:10:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] x86: Convert cpu_sibling_map to be a per cpu
 variable (v2)
Message-Id: <20070901091040.a55afd28.akpm@linux-foundation.org>
In-Reply-To: <46D94E2E.5030605@linux.vnet.ibm.com>
References: <20070824222654.687510000@sgi.com>
	<20070824222948.851896000@sgi.com>
	<20070831194903.5d88a007.akpm@linux-foundation.org>
	<46D94E2E.5030605@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: travis@sgi.com, ak@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

> On Sat, 01 Sep 2007 17:04:06 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> Andrew Morton wrote:
> > On Fri, 24 Aug 2007 15:26:57 -0700 travis@sgi.com wrote:
> >
> >   
> >> Convert cpu_sibling_map from a static array sized by NR_CPUS to a
> >> per_cpu variable.  This saves sizeof(cpumask_t) * NR unused cpus.
> >> Access is mostly from startup and CPU HOTPLUG functions.
> >>     
> >
> > ia64 allmodconfig:
> >
> > kernel/sched.c: In function `cpu_to_phys_group':                                                                             kernel/sched.c:5937: error: `per_cpu__cpu_sibling_map' undeclared (first use in this function)                               kernel/sched.c:5937: error: (Each undeclared identifier is reported only once
> > kernel/sched.c:5937: error: for each function it appears in.)                                                                kernel/sched.c:5937: warning: type defaults to `int' in declaration of `type name'
> > kernel/sched.c:5937: error: invalid type argument of `unary *'                                                               kernel/sched.c: In function `build_sched_domains':                                                                           kernel/sched.c:6172: error: `per_cpu__cpu_sibling_map' undeclared (first use in this function)                               kernel/sched.c:6172: warning: type defaults to `int' in declaration of `type name'                                           kernel/sched.c:6172: error: invalid type argument of `unary *'                                                               kernel/sched.c:6183: warning: type defaults to `int' in declaration of `type name'                                           kernel/sched.c:6183: error: invalid type argument of `unary *'                                                               
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> >
> >
> >   
> Hi Andrew,
> 
> I get the exact build failure on ppc64 machine with 2.6.23-rc4-mm1.
> 

The ia64 workaround was to disable SCHED_SMT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
