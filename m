Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5BBBC6B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 12:41:11 -0400 (EDT)
Received: by iggg4 with SMTP id g4so17386942igg.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 09:41:11 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id mv8si7033058igb.62.2015.04.07.09.41.10
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 09:41:10 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [GIT PULL 00/16] perf/core improvements and fixes
Date: Tue,  7 Apr 2015 13:40:46 -0300
Message-Id: <1428424862-30032-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Arnaldo Carvalho de Melo <acme@kernel.org>, Adrian Hunter <adrian.hunter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@suse.de>, David Ahern <dsahern@gmail.com>, Don Zickus <dzickus@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, He Kuang <hekuang@huawei.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Olsa <jolsa@redhat.com>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Namhyung Kim <namhyung@kernel.org>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <peterz@infradead.org>, pi3orama@163.com, Stephane Eranian <eranian@google.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Wang Nan <wangnan0@huawei.com>, Yunlong Song <yunlong.song@huawei.com>, Zefan Li <lizefan@huawei.com>, Arnaldo Carvalho de Melo <acme@redhat.com>

Hi Ingo,

	Please consider pulling,

- Arnaldo

The following changes since commit 6645f3187f5beb64f7a40515cfa18f3889264ece:

  Merge tag 'perf-core-for-mingo' of git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux into perf/core (2015-04-03 07:00:02 +0200)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo

for you to fetch changes up to d083e5ff09eccc0afd44e02ec85f10c06271e93b:

  perf tools: Merge all perf_event_attr print functions (2015-04-07 13:25:05 -0300)

----------------------------------------------------------------
perf/core improvements and fixes:

- Teach about perf_event_attr.clockid to 'perf record' (Peter Zijlstra)

- perf sched replay improvements for high CPU core count machines (Yunlong Song)

- Consider PERF_RECORD_ events with cpumode == 0 in 'perf top', removing one
  cause of long term memory usage buildup, i.e. not processing PERF_RECORD_EXIT
  events (Arnaldo Carvalho de Melo)

- Respect -i option 'in perf kmem' (Jiri Olsa)

Infrastructure:

- Honor operator priority in libtraceevent (Namhyung Kim)

- Merge all perf_event_attr print functions (Peter Zijlstra)

- Check kmaps access to make code more robust (Wang Nan)

- Fix inverted logic in perf_mmap__empty() (He Kuang)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

----------------------------------------------------------------
Arnaldo Carvalho de Melo (1):
      perf top: Consider PERF_RECORD_ events with cpumode == 0

He Kuang (1):
      perf evlist: Fix inverted logic in perf_mmap__empty

Jiri Olsa (1):
      perf kmem: Respect -i option

Namhyung Kim (1):
      tools lib traceevent: Honor operator priority

Peter Zijlstra (2):
      perf record: Add clockid parameter
      perf tools: Merge all perf_event_attr print functions

Wang Nan (1):
      perf kmaps: Check kmaps to make code more robust

Yunlong Song (9):
      perf sched replay: Use struct task_desc instead of struct task_task for correct meaning
      perf sched replay: Increase the MAX_PID value to fix assertion failure problem
      perf sched replay: Alloc the memory of pid_to_task dynamically to adapt to the unexpected change of pid_max
      perf sched replay: Realloc the memory of pid_to_task stepwise to adapt to the different pid_max configurations
      perf sched replay: Fix the segmentation fault problem caused by pr_err in threads
      perf sched replay: Handle the dead halt of sem_wait when create_tasks() fails for any task
      perf sched replay: Fix the EMFILE error caused by the limitation of the maximum open files
      perf sched replay: Support using -f to override perf.data file ownership
      perf sched replay: Use replay_repeat to calculate the runavg of cpu usage instead of the default value 10

 tools/lib/traceevent/event-parse.c       |  17 +-
 tools/perf/Documentation/perf-record.txt |   7 +
 tools/perf/builtin-kmem.c                |   3 +-
 tools/perf/builtin-record.c              |  80 ++++++++
 tools/perf/builtin-sched.c               |  67 +++++--
 tools/perf/builtin-top.c                 |   8 +-
 tools/perf/perf.h                        |   2 +
 tools/perf/util/evlist.c                 |   2 +-
 tools/perf/util/evsel.c                  | 325 ++++++++++++++++---------------
 tools/perf/util/evsel.h                  |   6 +
 tools/perf/util/header.c                 |  28 +--
 tools/perf/util/machine.c                |   5 +-
 tools/perf/util/map.c                    |  20 ++
 tools/perf/util/map.h                    |   6 +-
 tools/perf/util/probe-event.c            |   2 +
 tools/perf/util/session.c                |   3 +
 tools/perf/util/symbol-elf.c             |  16 +-
 tools/perf/util/symbol.c                 |  34 +++-
 18 files changed, 422 insertions(+), 209 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
