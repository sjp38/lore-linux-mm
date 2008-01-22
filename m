Date: Tue, 22 Jan 2008 13:48:11 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/3] x86: Reduce memory usage for large count NR_CPUs
	fixup V2 with git-x86
Message-ID: <20080122124811.GD7304@elte.hu>
References: <20080121211618.599818000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080121211618.599818000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* travis@sgi.com <travis@sgi.com> wrote:

> Fixup change NR_CPUS patchset by rebasing on 2.6.24-rc8-mm1
> from 2.6.24-rc6-mm1) and adding changes suggested by reviews.
> 
> Based on 2.6.24-rc8-mm1 + latest (08/1/21) git-x86
> 
> Note there are two versions of this patchset:
> 	- 2.6.24-rc8-mm1
> 	- 2.6.24-rc8-mm1 + latest (08/1/21) git-x86

thanks, applied.

> Signed-off-by: Mike Travis <travis@sgi.com>
> ---
> Fixup-V2:
>     - pulled the SMP_MAX patch as it's not strictly needed and some
>       more work on local cpumask_t variables needs to be done before
>       NR_CPUS is allowed to increase.

i'd still love to see CONFIG_SMP_MAX, so that we can have continuous 
randconfig testing of the large-SMP aspects of the x86 architecture, 
even on smaller systems.

What's the maximum that should work right now? 256 or perhaps even 512 
CPU ought to work fine i think?

and then once the on-stack usage problems are fixed, the NR_CPUS value 
in CONFIG_SMP_MAX can be increased. So SMP_MAX would also act as "this 
is how far we can go in the upstream kernel" documentation.

[ btw., the crash i remember was rather related to the NODES_SHIFT
  increase to 9, not from the NR_CPUSs increase. (the config i sent 
  still has NR_CPUS==8, because Kconfig did not pick up the right 
  NR_CPUs value dicatated by SMP_MAX.) If you resend the SMP_MAX patch 
  against latest x86.git i can retest this. ]

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
