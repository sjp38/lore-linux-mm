Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 94F1B6B006A
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 07:33:01 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so1429386waf.22
        for <linux-mm@kvack.org>; Tue, 17 Feb 2009 04:33:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1234871651.4744.89.camel@laptop>
References: <1234863220.4744.34.camel@laptop> <499A99BC.2080700@bk.jp.nec.com>
	 <20090217201651.576E.A69D9226@jp.fujitsu.com>
	 <1234871651.4744.89.camel@laptop>
Date: Tue, 17 Feb 2009 21:33:00 +0900
Message-ID: <2f11576a0902170433x52b63a05ie96601c741c3fc7a@mail.gmail.com>
Subject: Re: [PATCH] Add tracepoints to track pagecache transition
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>, linux-kernel@vger.kernel.org, Jason Baron <jbaron@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mathieu Desnoyers <compudj@krystal.dyndns.org>, "Frank Ch. Eigler" <fche@redhat.com>, Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>, rostedt@goodmis.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
List-ID: <linux-mm.kvack.org>

>> If you want to see I/O activity, you need to add tracepoint into block
>> layer.
>
> We already have that, Arnaldo converted blktrace to use tracepoints and
> wrote an ftrace tracer for it.

Yup. I agree I selected wrong word.
My point is, if he want to know I/O delaying reason, the number of the
cache pages seems unrelated thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
