Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 29FA06B006C
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 09:41:01 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so43876314igb.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:41:01 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id q9si4559448iga.19.2015.04.13.06.41.00
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 06:41:00 -0700 (PDT)
Date: Mon, 13 Apr 2015 10:40:56 -0300
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 3/9] perf kmem: Analyze page allocator events also
Message-ID: <20150413134056.GE3200@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
 <1428298576-9785-4-git-send-email-namhyung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1428298576-9785-4-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Em Mon, Apr 06, 2015 at 02:36:10PM +0900, Namhyung Kim escreveu:
> The perf kmem command records and analyze kernel memory allocation
> only for SLAB objects.  This patch implement a simple page allocator
> analyzer using kmem:mm_page_alloc and kmem:mm_page_free events.
> 
> It adds two new options of --slab and --page.  The --slab option is
> for analyzing SLAB allocator and that's what perf kmem currently does.
> 
> The new --page option enables page allocator events and analyze kernel
> memory usage in page unit.  Currently, 'stat --alloc' subcommand is
> implemented only.
> 
> If none of these --slab nor --page is specified, --slab is implied.
> 
>   # perf kmem stat --page --alloc --line 10

Applied this and the kernel part, tested, thanks,

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
