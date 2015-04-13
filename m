Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 39B0B6B0038
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 18:33:16 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so116522912pab.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 15:33:16 -0700 (PDT)
Received: from mail7.hitachi.co.jp (mail7.hitachi.co.jp. [133.145.228.42])
        by mx.google.com with ESMTP id tb7si17737674pac.140.2015.04.13.15.33.14
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 15:33:15 -0700 (PDT)
Message-ID: <552C4423.6020001@hitachi.com>
Date: Tue, 14 Apr 2015 07:33:07 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [GIT PULL 0/5] perf/core improvements and fixes
References: <1428963302-31538-1-git-send-email-acme@kernel.org>
In-Reply-To: <1428963302-31538-1-git-send-email-acme@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, David Ahern <dsahern@gmail.com>, He Kuang <hekuang@huawei.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Namhyung Kim <namhyung@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>, Wang Nan <wangnan0@huawei.com>, Arnaldo Carvalho de Melo <acme@redhat.com>

Hi, Arnaldo,

>       perf probe: Make --source avaiable when probe with lazy_line

No, could you pull Naohiro's patch?
I'd like to move get_real_path to probe_finder.c

Thank you,

(2015/04/14 7:14), Arnaldo Carvalho de Melo wrote:
> Hi Ingo,
> 
> 	Please consider pulling,
> 
> Best regards,
> 
> - Arnaldo
> 
> The following changes since commit 066450be419fa48007a9f29e19828f2a86198754:
> 
>   perf/x86/intel/pt: Clean up the control flow in pt_pmu_hw_init() (2015-04-12 11:21:15 +0200)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo
> 
> for you to fetch changes up to be8d5b1c6b468d10bd2928bbd1a5ca3fd2980402:
> 
>   perf probe: Fix segfault when probe with lazy_line to file (2015-04-13 17:59:41 -0300)
> 
> ----------------------------------------------------------------
> perf/core improvements and fixes:
> 
> New features:
> 
> - Analyze page allocator events also in 'perf kmem' (Namhyung Kim)
> 
> User visible fixes:
> 
> - Fix retprobe 'perf probe' handling when failing to find needed debuginfo (He Kuang)
> 
> - lazy_line probe fixes in 'perf probe' (He Kuang)
> 
> Infrastructure:
> 
> - Record pfn instead of pointer to struct page in tracepoints (Namhyung Kim)
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> ----------------------------------------------------------------
> He Kuang (3):
>       perf probe: Set retprobe flag when probe in address-based alternative mode
>       perf probe: Make --source avaiable when probe with lazy_line
>       perf probe: Fix segfault when probe with lazy_line to file
> 
> Namhyung Kim (2):
>       tracing, mm: Record pfn instead of pointer to struct page
>       perf kmem: Analyze page allocator events also
> 
>  include/trace/events/filemap.h         |   8 +-
>  include/trace/events/kmem.h            |  42 +--
>  include/trace/events/vmscan.h          |   8 +-
>  tools/perf/Documentation/perf-kmem.txt |   8 +-
>  tools/perf/builtin-kmem.c              | 500 +++++++++++++++++++++++++++++++--
>  tools/perf/util/probe-event.c          |   3 +-
>  tools/perf/util/probe-event.h          |   2 +
>  tools/perf/util/probe-finder.c         |  20 +-
>  8 files changed, 540 insertions(+), 51 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> 


-- 
Masami HIRAMATSU
Linux Technology Research Center, System Productivity Research Dept.
Center for Technology Innovation - Systems Engineering
Hitachi, Ltd., Research & Development Group
E-mail: masami.hiramatsu.pt@hitachi.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
