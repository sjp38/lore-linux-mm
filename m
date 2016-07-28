Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2C236B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 16:11:28 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ca5so67949734pac.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 13:11:28 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id xz3si13859974pab.244.2016.07.28.13.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 13:11:27 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id ez1so4009751pab.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 13:11:27 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <20160727112303.11409a4e@gandalf.local.home>
Date: Fri, 29 Jul 2016 01:41:20 +0530
Content-Transfer-Encoding: quoted-printable
Message-Id: <0AF03F78-AA34-4531-899A-EA1076B6B3A1@gmail.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com> <6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com> <20160727112303.11409a4e@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com


> On Jul 27, 2016, at 8:53 PM, Steven Rostedt <rostedt@goodmis.org> =
wrote:
>=20
> I'm thinking you only need one tracepoint, and use function_graph
> tracer for the length of the function call.
>=20
> # cd /sys/kernel/debug/tracing
> # echo __alloc_pages_nodemask > set_ftrace_filter
> # echo function_graph > current_tracer
> # echo 1 > events/kmem/trace_mm_slowpath/enable

Thank you so much for your feedback!=20

Actually, the goal is to only single out those cases with latencies =
higher than a given
threshold.

So, in accordance with this, I added those begin/end tracepoints and =
thought I=20
could use a script to read the output of trace_pipe and only write to =
disk the trace=20
information associated with latencies above the threshold. This would =
help prevent=20
high disk I/O, especially when the threshold set is high.

I looked at function graph trace, as you=E2=80=99d suggested. I saw that =
I could set a threshold=20
there using tracing_thresh. But the problem was that slowpath trace =
information was printed
for all the cases (even when __alloc_pages_nodemask latencies were below =
the threshold).
Is there a way to print tracepoint information only when =
__alloc_pages_nodemask
exceeds the threshold?

Thanks!

Janani.
>=20
> -- Steve
>=20
>=20
>> 	return page;
>> }
>>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
