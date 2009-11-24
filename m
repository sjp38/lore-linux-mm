Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 357986B006A
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 00:26:08 -0500 (EST)
Message-ID: <4B0B6E44.6090106@cn.fujitsu.com>
Date: Tue, 24 Nov 2009 13:25:24 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 0/5] perf kmem: Add more functions and show more statistics
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

List of new things:

- Add option "--raw-ip", to print raw ip instead of symbols.

- Sort the output by fragmentation by default, and support
  multi keys.

- Collect and show cross node allocation stats.

- Collect and show alloc/free ping-pong stats.

- And help file.

---
 tools/perf/Documentation/perf-kmem.txt |   44 ++++
 tools/perf/builtin-kmem.c              |  353 ++++++++++++++++++++++++++------
 tools/perf/command-list.txt            |    1 +
 3 files changed, 331 insertions(+), 67 deletions(-)


Pekka, do you think we can remove kmemtrace now?

With kmem trace events, low-level analyzing can be done using
ftrace, and high-level analyzing can be done using perf-kmem.

And chance is, more people may use and improve perf-kmem, and it
will be well-maintained within the perf infrastructure. On the
other hand, I guess few people use and contribute to kmemtrace-user.

BTW, seems kmemtrace-user doesn't work with ftrace. I got setfault:

	# ./kmemtraced
	Copying /proc/kallsyms...
	Logging... Press Control-C to stop.
	^CSegmentation fault


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
