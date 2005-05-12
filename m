Date: Thu, 12 May 2005 09:14:01 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Avoiding mmap fragmentation  (against 2.6.12-rc4) to
Message-ID: <20050512071401.GA16345@elte.hu>
References: <20050510115818.0828f5d1.akpm@osdl.org> <200505101934.j4AJYfg26483@unix-os.sc.intel.com> <20050510124357.2a7d2f9b.akpm@osdl.org> <17025.4213.255704.748374@gargle.gargle.HOWL> <20050510125747.65b83b4c.akpm@osdl.org> <17026.6227.225173.588629@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <17026.6227.225173.588629@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wolfgang Wander <wwc@rentec.com>
Cc: Andrew Morton <akpm@osdl.org>, kenneth.w.chen@intel.com, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Wolfgang Wander <wwc@rentec.com> wrote:

> Now - drumroll ;-) the appended patch works fine with leakme: it ends 
> with only 7 distinct areas in /proc/self/maps and also thread creation 
> seems sufficiently fast with 0.71s for 20000 threads.

great! Looks good to me. The whole allocator is a bit of a patchwork, 
but we knew that: the optimizations are heuristics so there will always 
be workloads where the linear search could trigger. (If someone replaces 
the whole thing with some smart size and address indexed tree structure 
it may work better, but i'm not holding my breath.)

This needs tons of testing though.

	Ingo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
