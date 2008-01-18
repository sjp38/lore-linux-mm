Message-ID: <4790F49C.3050002@sgi.com>
Date: Fri, 18 Jan 2008 10:49:00 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] x86: Add debug of invalid per_cpu map accesses
References: <20080118183011.354965000@sgi.com> <20080118183012.050317000@sgi.com> <200801181933.05662.ak@suse.de>
In-Reply-To: <200801181933.05662.ak@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Friday 18 January 2008 19:30:16 travis@sgi.com wrote:
>> Provide a means to trap usages of per_cpu map variables before
>> they are setup.  Define CONFIG_DEBUG_PER_CPU_MAPS to activate.
> 
> Are you sure that debug option is generally useful enough
> to merge? It seems very specific to your patchkit, but I'm not
> sure it would be worth carrying forever in the kernel.
> 
> Better would be probably to just unmap those areas anyways.
> 
> -Andi

I thought for a round of testing it'd be worthwhile, particularly
testing randconfig.  The next version of percpu changes are coming
soon and I can remove them then.  Ideally, you are right, it'd
be nice to not have the percpu memory mapped for processors that are
not present.

One thing that comes into play is that (soon) the boot_pda will be
in the per_cpu area and it's maintained for all "possible" cpus as
it keeps track of some info on "off-lined" cpus.  What I was thinking
is that perhaps no memory is allocated (and mapped) until a cpu
becomes not only possible, but probable.  This means that until a
cpu is brought online, or discovered via ACPI, then there is no percpu
area and access to an invalid percpu area causes a kernel fault.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
