From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX II
Date: Fri, 18 Jan 2008 22:02:43 +0100
References: <20080118183011.354965000@sgi.com> <479108C3.1010800@sgi.com> <200801182136.15213.ak@suse.de>
In-Reply-To: <200801182136.15213.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801182202.43151.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Ingo Oeser <ioe-lkml@rameria.de>, Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > Here are the top stack consumers with NR_CPUS = 4k.
> > 
> >                          16392 isolated_cpu_setup
> >                          10328 build_sched_domains
> >                           8248 numa_initmem_init
> 
> These should run single threaded early at boot so you can probably just make
> the cpumask_t variables static __initdata


To correct myself: this is not true for build_sched_domains() which can
be triggered from sysfs.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
