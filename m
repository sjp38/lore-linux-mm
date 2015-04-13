Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id EB21F6B0038
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 09:21:06 -0400 (EDT)
Received: by iejt8 with SMTP id t8so63941530iej.2
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:21:06 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id m20si3943037ics.103.2015.04.13.06.21.05
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 06:21:06 -0700 (PDT)
Date: Mon, 13 Apr 2015 10:21:00 -0300
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 3/9] perf kmem: Analyze page allocator events also
Message-ID: <20150413132100.GC3200@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
 <1428298576-9785-4-git-send-email-namhyung@kernel.org>
 <20150410210629.GF4521@kernel.org>
 <20150410211049.GA17496@kernel.org>
 <20150413065924.GH23913@sejong>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150413065924.GH23913@sejong>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Em Mon, Apr 13, 2015 at 03:59:24PM +0900, Namhyung Kim escreveu:
> On Fri, Apr 10, 2015 at 06:10:49PM -0300, Arnaldo Carvalho de Melo wrote:
> > Em Fri, Apr 10, 2015 at 06:06:29PM -0300, Arnaldo Carvalho de Melo escreveu:
> > > Em Mon, Apr 06, 2015 at 02:36:10PM +0900, Namhyung Kim escreveu:
> > > > If none of these --slab nor --page is specified, --slab is implied.

> > > >   # perf kmem stat --page --alloc --line 10

> > > Hi, applied the first patch, the kernel one, reboot with that kernel:

> > <SNIP>

> > > [root@ssdandy ~]#

> > > What am I missing?

> > Argh, I was expecting to read just what is in that cset and be able to
> > reproduce the results, had to go back to the [PATCH 0/0] cover letter to
> > figure out that I need to run:

> > perf kmem record --page sleep 5

> Right.  Maybe I need to change to print warning if no events found
> with option.

Ok!

> Hmm.. looks like you ran some old version.  Please check v6! :)

Thanks, will do,

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
