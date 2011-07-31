Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E4D88900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 16:45:49 -0400 (EDT)
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger>
	 <alpine.DEB.2.00.1107291002570.16178@router.home>
	 <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Sun, 31 Jul 2011 23:45:46 +0300
Message-ID: <1312145146.24862.97.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 2011-07-31 at 13:24 -0700, David Rientjes wrote:
> And although slub is definitely heading in the right direction regarding 
> the netperf benchmark, it's still a non-starter for anybody using large 
> NUMA machines for networking performance.  On my 16-core, 4 node, 64GB 
> client/server machines running netperf TCP_RR with various thread counts 
> for 60 seconds each on 3.0:
> 
> 	threads		SLUB		SLAB		diff
> 	 16		76345		74973		- 1.8%
> 	 32		116380		116272		- 0.1%
> 	 48		150509		153703		+ 2.1%
> 	 64		187984		189750		+ 0.9%
> 	 80		216853		224471		+ 3.5%
> 	 96		236640		249184		+ 5.3%
> 	112		256540		275464		+ 7.4%
> 	128		273027		296014		+ 8.4%
> 	144		281441		314791		+11.8%
> 	160		287225		326941		+13.8%

That looks like a pretty nasty scaling issue. David, would it be
possible to see 'perf report' for the 160 case? [ Maybe even 'perf
annotate' for the interesting SLUB functions. ]

On Sun, 2011-07-31 at 13:24 -0700, David Rientjes wrote:
> And although I've developed a mutable slab allocator, SLAM, that makes all 
> of this irrelevant since it's a drop-in replacement for slab and slub, I 
> can't legitimately propose it for inclusion because it lacks the debugging 
> capabilities that slub excels in and there's an understanding that Linus 
> won't merge another stand-alone allocator until one is removed.

Nick tried that with SLQB and it didn't work out. I actually even tried
to maintain it out-of-tree for a while but eventually gave up. So no,
I'm not interested in merging a new allocator either. I would be,
however, interested to see the source code.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
