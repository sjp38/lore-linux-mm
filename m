Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 487FB6B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 11:05:21 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so91482229wgb.1
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 08:05:20 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id ey9si19080625wid.37.2015.04.08.08.05.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 08:05:17 -0700 (PDT)
Received: by wiaa2 with SMTP id a2so62386706wia.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 08:05:16 -0700 (PDT)
Date: Wed, 8 Apr 2015 17:05:11 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [GIT PULL 00/19] perf/core improvements and fixes
Message-ID: <20150408150511.GA3684@gmail.com>
References: <1428503019-23820-1-git-send-email-acme@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1428503019-23820-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: linux-kernel@vger.kernel.org, Adrian Hunter <adrian.hunter@intel.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, David Ahern <dsahern@gmail.com>, Frederic Weisbecker <fweisbec@gmail.com>, He Kuang <hekuang@huawei.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Olsa <jolsa@redhat.com>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Kaixu Xia <kaixu.xia@linaro.org>, Kan Liang <kan.liang@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Markus T Metzger <markus.t.metzger@intel.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Mathieu Poirier <mathieu.poirier@linaro.org>, Mike Galbraith <efault@gmx.de>, Minchan Kim <minchan@kernel.org>, Namhyung Kim <namhyung@kernel.org>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <peterz@infradead.org>, pi3orama@163.com, Robert Richter <rric@kernel.org>, Stephane Eranian <eranian@google.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Wang Nan <wangnan0@huawei.com>, William Cohen <wcohen@redhat.com>, Yunlong Song <yunlong.song@huawei.com>, Zefan Li <lizefan@huawei.com>, Arnaldo Carvalho de Melo <acme@redhat.com>


* Arnaldo Carvalho de Melo <acme@kernel.org> wrote:

> Hi Ingo,
> 
>         Please consider pulling, it is the pull req from yesterday, minus a patch
> that introduced a problem, plus a fex fixes.
> 
>         I am investigating a problem I noticed for another patch that is upstream
> and after that will get back to the removed patch from yesterday's batch,
> 
> - Arnaldo
> 
> The following changes since commit 6645f3187f5beb64f7a40515cfa18f3889264ece:
> 
>   Merge tag 'perf-core-for-mingo' of git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux into perf/core (2015-04-03 07:00:02 +0200)
> 
> are available in the git repository at:
> 
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo
> 
> for you to fetch changes up to a1e12da4796a4ddd0e911687a290eb396d1c64bf:
> 
>   perf tools: Add 'I' event modifier for exclude_idle bit (2015-04-08 11:00:16 -0300)
> 
> ----------------------------------------------------------------
> perf/core improvements and fixes:
> 
> - Teach about perf_event_attr.clockid to 'perf record' (Peter Zijlstra)
> 
> - perf sched replay improvements for high CPU core count machines (Yunlong Song)
> 
> - Consider PERF_RECORD_ events with cpumode == 0 in 'perf top', removing one
>   cause of long term memory usage buildup, i.e. not processing PERF_RECORD_EXIT
>   events (Arnaldo Carvalho de Melo)
> 
> - Add 'I' event modifier for perf_event_attr.exclude_idle bit (Jiri Olsa)
> 
> - Respect -i option 'in perf kmem' (Jiri Olsa)
> 
> Infrastructure:
> 
> - Honor operator priority in libtraceevent (Namhyung Kim)
> 
> - Merge all perf_event_attr print functions (Peter Zijlstra)
> 
> - Check kmaps access to make code more robust (Wang Nan)
> 
> - Fix inverted logic in perf_mmap__empty() (He Kuang)
> 
> - Fix ARM 32 'perf probe' building error (Wang Nan)
> 
> - Fix perf_event_attr tests (Jiri Olsa)
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> ----------------------------------------------------------------
> He Kuang (1):
>       perf evlist: Fix inverted logic in perf_mmap__empty
> 
> Jiri Olsa (3):
>       perf kmem: Respect -i option
>       perf tests: Fix attr tests
>       perf tools: Add 'I' event modifier for exclude_idle bit
> 
> Namhyung Kim (1):
>       tools lib traceevent: Honor operator priority
> 
> Peter Zijlstra (2):
>       perf record: Add clockid parameter
>       perf tools: Merge all perf_event_attr print functions
> 
> Wang Nan (3):
>       perf kmaps: Check kmaps to make code more robust
>       perf probe: Fix ARM 32 building error
>       perf report: Don't call map__kmap if map is NULL.
> 
> Yunlong Song (9):
>       perf sched replay: Use struct task_desc instead of struct task_task for correct meaning
>       perf sched replay: Increase the MAX_PID value to fix assertion failure problem
>       perf sched replay: Alloc the memory of pid_to_task dynamically to adapt to the unexpected change of pid_max
>       perf sched replay: Realloc the memory of pid_to_task stepwise to adapt to the different pid_max configurations
>       perf sched replay: Fix the segmentation fault problem caused by pr_err in threads
>       perf sched replay: Handle the dead halt of sem_wait when create_tasks() fails for any task
>       perf sched replay: Fix the EMFILE error caused by the limitation of the maximum open files
>       perf sched replay: Support using -f to override perf.data file ownership
>       perf sched replay: Use replay_repeat to calculate the runavg of cpu usage instead of the default value 10
> 
>  tools/lib/traceevent/event-parse.c       |  17 +-
>  tools/perf/Documentation/perf-list.txt   |   1 +
>  tools/perf/Documentation/perf-record.txt |   7 +
>  tools/perf/builtin-kmem.c                |   3 +-
>  tools/perf/builtin-record.c              |  87 +++++++++
>  tools/perf/builtin-report.c              |   2 +-
>  tools/perf/builtin-sched.c               |  67 +++++--
>  tools/perf/perf.h                        |   2 +
>  tools/perf/tests/attr/base-record        |   2 +-
>  tools/perf/tests/attr/base-stat          |   2 +-
>  tools/perf/tests/parse-events.c          |  40 ++++
>  tools/perf/util/evlist.c                 |   2 +-
>  tools/perf/util/evsel.c                  | 325 ++++++++++++++++---------------
>  tools/perf/util/evsel.h                  |   6 +
>  tools/perf/util/header.c                 |  28 +--
>  tools/perf/util/machine.c                |   5 +-
>  tools/perf/util/map.c                    |  20 ++
>  tools/perf/util/map.h                    |   6 +-
>  tools/perf/util/parse-events.c           |   8 +-
>  tools/perf/util/parse-events.l           |   2 +-
>  tools/perf/util/probe-event.c            |   5 +-
>  tools/perf/util/session.c                |   3 +
>  tools/perf/util/symbol-elf.c             |  16 +-
>  tools/perf/util/symbol.c                 |  34 +++-
>  24 files changed, 477 insertions(+), 213 deletions(-)

Pulled, thanks a lot Arnaldo!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
