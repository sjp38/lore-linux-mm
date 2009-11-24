Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3A06B007B
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 17:35:04 -0500 (EST)
Date: Tue, 24 Nov 2009 23:34:43 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/5] perf kmem: Add more functions and show more
 statistics
Message-ID: <20091124223443.GA7189@elte.hu>
References: <4B0B6E44.6090106@cn.fujitsu.com>
 <20091124090425.GF21991@elte.hu>
 <4B0BA99D.5020602@cn.fujitsu.com>
 <20091124100724.GA5570@elte.hu>
 <4B0BBDBF.6050806@cn.fujitsu.com>
 <20091124203559.GA450@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091124203559.GA450@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> > So I think some new updates on kernel perf_event break.
> 
> yeah, you were right. This commit in latest -tip should fix it:
> 
>  fe61267: perf_events: Fix bad software/trace event recursion counting

i tested perf kmem and it works fine now:

 aldebaran:~> perf kmem

 SUMMARY
 =======
 Total bytes requested: 153166032
 Total bytes allocated: 188544080
 Total bytes wasted on internal fragmentation: 35378048
 Internal fragmentation: 18.763807%
 Cross CPU allocations: 61680/451425

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
