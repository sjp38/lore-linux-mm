From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX
Date: Mon, 28 Jan 2008 18:00:24 +0100
References: <20080118183011.354965000@sgi.com> <479108C3.1010800@sgi.com> <20080128104520.e1e6c878.pj@sgi.com>
In-Reply-To: <20080128104520.e1e6c878.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801281800.24780.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Mike Travis <travis@sgi.com>, ioe-lkml@rameria.de, akpm@linux-foundation.org, mingo@elte.hu, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> The problem in kernel/sched.c:isolated_cpu_setup() is an array of
> NR_CPUS integers:
> 
>     static int __init isolated_cpu_setup(char *str)
>     {
> 	    int ints[NR_CPUS], i;
> 
> 	    str = get_options(str, ARRAY_SIZE(ints), ints);
> 
> Since isolated_cpu_setup() is an __init routine, perhaps we could
> make that ints[] array static __initdata?

That or use alloc_bootmem / free_bootmem

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
