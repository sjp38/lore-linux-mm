Date: Fri, 31 Aug 2007 19:49:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] x86: Convert cpu_sibling_map to be a per cpu
 variable (v2)
Message-Id: <20070831194903.5d88a007.akpm@linux-foundation.org>
In-Reply-To: <20070824222948.851896000@sgi.com>
References: <20070824222654.687510000@sgi.com>
	<20070824222948.851896000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 24 Aug 2007 15:26:57 -0700 travis@sgi.com wrote:

> Convert cpu_sibling_map from a static array sized by NR_CPUS to a
> per_cpu variable.  This saves sizeof(cpumask_t) * NR unused cpus.
> Access is mostly from startup and CPU HOTPLUG functions.

ia64 allmodconfig:

kernel/sched.c: In function `cpu_to_phys_group':                                                                             kernel/sched.c:5937: error: `per_cpu__cpu_sibling_map' undeclared (first use in this function)                               kernel/sched.c:5937: error: (Each undeclared identifier is reported only once
kernel/sched.c:5937: error: for each function it appears in.)                                                                kernel/sched.c:5937: warning: type defaults to `int' in declaration of `type name'
kernel/sched.c:5937: error: invalid type argument of `unary *'                                                               kernel/sched.c: In function `build_sched_domains':                                                                           kernel/sched.c:6172: error: `per_cpu__cpu_sibling_map' undeclared (first use in this function)                               kernel/sched.c:6172: warning: type defaults to `int' in declaration of `type name'                                           kernel/sched.c:6172: error: invalid type argument of `unary *'                                                               kernel/sched.c:6183: warning: type defaults to `int' in declaration of `type name'                                           kernel/sched.c:6183: error: invalid type argument of `unary *'                                                               

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
