Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 970706B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 15:53:35 -0500 (EST)
Date: Tue, 24 Nov 2009 21:35:59 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/5] perf kmem: Add more functions and show more
 statistics
Message-ID: <20091124203559.GA450@elte.hu>
References: <4B0B6E44.6090106@cn.fujitsu.com>
 <20091124090425.GF21991@elte.hu>
 <4B0BA99D.5020602@cn.fujitsu.com>
 <20091124100724.GA5570@elte.hu>
 <4B0BBDBF.6050806@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B0BBDBF.6050806@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Li Zefan <lizf@cn.fujitsu.com> wrote:

> So I think some new updates on kernel perf_event break.

yeah, you were right. This commit in latest -tip should fix it:

 fe61267: perf_events: Fix bad software/trace event recursion counting

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
