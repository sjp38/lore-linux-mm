Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4017B6B0062
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 06:54:27 -0500 (EST)
Subject: Re: [PATCH] Add tracepoints to track pagecache transition
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090217201651.576E.A69D9226@jp.fujitsu.com>
References: <1234863220.4744.34.camel@laptop>
	 <499A99BC.2080700@bk.jp.nec.com>
	 <20090217201651.576E.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 17 Feb 2009 12:54:11 +0100
Message-Id: <1234871651.4744.89.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>, linux-kernel@vger.kernel.org, Jason Baron <jbaron@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mathieu Desnoyers <compudj@krystal.dyndns.org>, "Frank Ch. Eigler" <fche@redhat.com>, Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>, rostedt@goodmis.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-02-17 at 20:38 +0900, KOSAKI Motohiro wrote:
> If you want to see I/O activity, you need to add tracepoint into block
> layer.

We already have that, Arnaldo converted blktrace to use tracepoints and
wrote an ftrace tracer for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
