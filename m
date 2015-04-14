Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 33CA76B0032
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 08:12:53 -0400 (EDT)
Received: by widdi4 with SMTP id di4so110558814wid.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 05:12:52 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id fc9si1614805wjc.177.2015.04.14.05.12.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 05:12:51 -0700 (PDT)
Received: by wgyo15 with SMTP id o15so9542370wgy.2
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 05:12:51 -0700 (PDT)
Date: Tue, 14 Apr 2015 14:12:46 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [GIT PULL 0/5] perf/core improvements and fixes
Message-ID: <20150414121245.GB23761@gmail.com>
References: <1428963302-31538-1-git-send-email-acme@kernel.org>
 <552C4423.6020001@hitachi.com>
 <20150413230923.GA16027@kernel.org>
 <20150413231934.GC16027@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150413231934.GC16027@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, linux-kernel@vger.kernel.org, David Ahern <dsahern@gmail.com>, He Kuang <hekuang@huawei.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Namhyung Kim <namhyung@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>, Wang Nan <wangnan0@huawei.com>


* Arnaldo Carvalho de Melo <acme@kernel.org> wrote:

> Em Mon, Apr 13, 2015 at 08:09:23PM -0300, Arnaldo Carvalho de Melo escreveu:
> > Em Tue, Apr 14, 2015 at 07:33:07AM +0900, Masami Hiramatsu escreveu:
> > > Hi, Arnaldo,
> > > 
> > > >       perf probe: Make --source avaiable when probe with lazy_line
> > > 
> > > No, could you pull Naohiro's patch?
> > > I'd like to move get_real_path to probe_finder.c
> > 
> > OOps, yeah, you asked for that... Ingo, please ignore this pull request
> > for now, thanks,
> 
> Ok, I did that and created a perf-core-for-mingo-2, Masami, please check
> that all is right, ok?
> 
> - Arnaldo
> 
> The following changes since commit 066450be419fa48007a9f29e19828f2a86198754:
> 
>   perf/x86/intel/pt: Clean up the control flow in pt_pmu_hw_init() (2015-04-12 11:21:15 +0200)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo-2
> 
> for you to fetch changes up to f19e80c640d58ddfd70f2454ee597f81ba966690:
> 
>   perf probe: Fix segfault when probe with lazy_line to file (2015-04-13 20:12:21 -0300)
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
> - lazy_line probe fixes in 'perf probe' (Naohiro Aota, He Kuang)
> 
> Infrastructure:
> 
> - Record pfn instead of pointer to struct page in tracepoints (Namhyung Kim)
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> ----------------------------------------------------------------
> He Kuang (2):
>       perf probe: Set retprobe flag when probe in address-based alternative mode
>       perf probe: Fix segfault when probe with lazy_line to file
> 
> Namhyung Kim (2):
>       tracing, mm: Record pfn instead of pointer to struct page
>       perf kmem: Analyze page allocator events also
> 
> Naohiro Aota (1):
>       perf probe: Find compilation directory path for lazy matching
> 
>  include/trace/events/filemap.h         |   8 +-
>  include/trace/events/kmem.h            |  42 +--
>  include/trace/events/vmscan.h          |   8 +-
>  tools/perf/Documentation/perf-kmem.txt |   8 +-
>  tools/perf/builtin-kmem.c              | 500 +++++++++++++++++++++++++++++++--
>  tools/perf/util/probe-event.c          |  60 +---
>  tools/perf/util/probe-finder.c         |  73 ++++-
>  tools/perf/util/probe-finder.h         |   4 +
>  8 files changed, 596 insertions(+), 107 deletions(-)

Pulled, thanks a lot Arnaldo!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
