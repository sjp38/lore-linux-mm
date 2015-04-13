Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id E90606B0038
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 18:15:18 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so59036964igb.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 15:15:18 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id cv17si89073icb.61.2015.04.13.15.15.18
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 15:15:18 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [GIT PULL 0/5] perf/core improvements and fixes
Date: Mon, 13 Apr 2015 19:14:57 -0300
Message-Id: <1428963302-31538-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Arnaldo Carvalho de Melo <acme@kernel.org>, David Ahern <dsahern@gmail.com>, He Kuang <hekuang@huawei.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Minchan Kim <minchan@kernel.org>, Namhyung Kim <namhyung@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>, Wang Nan <wangnan0@huawei.com>, Arnaldo Carvalho de Melo <acme@redhat.com>

Hi Ingo,

	Please consider pulling,

Best regards,

- Arnaldo

The following changes since commit 066450be419fa48007a9f29e19828f2a86198754:

  perf/x86/intel/pt: Clean up the control flow in pt_pmu_hw_init() (2015-04-12 11:21:15 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo

for you to fetch changes up to be8d5b1c6b468d10bd2928bbd1a5ca3fd2980402:

  perf probe: Fix segfault when probe with lazy_line to file (2015-04-13 17:59:41 -0300)

----------------------------------------------------------------
perf/core improvements and fixes:

New features:

- Analyze page allocator events also in 'perf kmem' (Namhyung Kim)

User visible fixes:

- Fix retprobe 'perf probe' handling when failing to find needed debuginfo (He Kuang)

- lazy_line probe fixes in 'perf probe' (He Kuang)

Infrastructure:

- Record pfn instead of pointer to struct page in tracepoints (Namhyung Kim)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

----------------------------------------------------------------
He Kuang (3):
      perf probe: Set retprobe flag when probe in address-based alternative mode
      perf probe: Make --source avaiable when probe with lazy_line
      perf probe: Fix segfault when probe with lazy_line to file

Namhyung Kim (2):
      tracing, mm: Record pfn instead of pointer to struct page
      perf kmem: Analyze page allocator events also

 include/trace/events/filemap.h         |   8 +-
 include/trace/events/kmem.h            |  42 +--
 include/trace/events/vmscan.h          |   8 +-
 tools/perf/Documentation/perf-kmem.txt |   8 +-
 tools/perf/builtin-kmem.c              | 500 +++++++++++++++++++++++++++++++--
 tools/perf/util/probe-event.c          |   3 +-
 tools/perf/util/probe-event.h          |   2 +
 tools/perf/util/probe-finder.c         |  20 +-
 8 files changed, 540 insertions(+), 51 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
