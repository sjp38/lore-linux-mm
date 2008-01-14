Date: Mon, 14 Jan 2008 09:14:18 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/10] x86: Reduce memory and intra-node effects with
	large count NR_CPUs
Message-ID: <20080114081418.GB18296@elte.hu>
References: <20080113183453.973425000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080113183453.973425000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* travis@sgi.com <travis@sgi.com> wrote:

> This patchset addresses the kernel bloat that occurs when NR_CPUS is 
> increased. The memory numbers below are with NR_CPUS = 1024 which I've 
> been testing (4 and 32 real processors, the rest "possible" using the 
> additional_cpus start option.) These changes are all specific to the 
> x86 architecture, non-arch specific changes will follow.

thanks, i'll try this patchset in x86.git.

> 32cpus			  1kcpus-before		    1kcpus-after
>    7172678 Total	   +23314404 Total	       -147590 Total

1kcpus-after means it's +23314404-147590, i.e. +23166814? (i.e. a 0.6% 
reduction of the bloat?)

i.e. we've got ~22K bloat per CPU - which is not bad, but because it's a 
static component, it hurts smaller boxes. For distributors to enable 
CONFIG_NR_CPU=1024 by default i guess that bloat has to drop below 1-2K 
per CPU :-/ [that would still mean 1-2MB total bloat but that's much 
more acceptable than 23MB]

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
