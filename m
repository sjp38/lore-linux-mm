Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7426B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 12:13:15 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so83405089ied.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 09:13:15 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0184.hostedemail.com. [216.40.44.184])
        by mx.google.com with ESMTP id 5si1183458iop.81.2015.03.27.09.13.14
        for <linux-mm@kvack.org>;
        Fri, 27 Mar 2015 09:13:14 -0700 (PDT)
Date: Fri, 27 Mar 2015 12:13:06 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/7] tracing, mm: Record pfn instead of pointer to
 struct page
Message-ID: <20150327121306.32ad44c1@gandalf.local.home>
In-Reply-To: <1427422087-17239-2-git-send-email-namhyung@kernel.org>
References: <1427422087-17239-1-git-send-email-namhyung@kernel.org>
	<1427422087-17239-2-git-send-email-namhyung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

On Fri, 27 Mar 2015 11:08:01 +0900
Namhyung Kim <namhyung@kernel.org> wrote:

> The struct page is opaque for userspace tools, so it'd be better to save
> pfn in order to identify page frames.
> 
> The textual output of $debugfs/tracing/trace file remains unchanged and
> only raw (binary) data format is changed - but thanks to libtraceevent,
> userspace tools which deal with the raw data (like perf and trace-cmd)
> can parse the format easily.  So impact on the userspace will also be
> minimal.
> 
> Based-on-patch-by: Joonsoo Kim <js1304@gmail.com>
> Acked-by: Ingo Molnar <mingo@kernel.org>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Namhyung Kim <namhyung@kernel.org>
> ---


Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
