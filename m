Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id F03156B004D
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 20:23:10 -0400 (EDT)
Date: Wed, 3 Apr 2013 09:23:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 4/4] mm: Enhance per process reclaim
Message-ID: <20130403002309.GD16026@blaptop>
References: <1364192494-22185-1-git-send-email-minchan@kernel.org>
 <1364192494-22185-4-git-send-email-minchan@kernel.org>
 <CAHO5Pa1LiBw8P5On0X3__49P8zeY4xwEU63KBoKWEpLTOHjeTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHO5Pa1LiBw8P5On0X3__49P8zeY4xwEU63KBoKWEpLTOHjeTw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sangseok Lee <sangseok.lee@lge.com>

Hey Michael,

On Tue, Apr 02, 2013 at 03:25:25PM +0200, Michael Kerrisk wrote:
> Minchan,
> 
> On Mon, Mar 25, 2013 at 7:21 AM, Minchan Kim <minchan@kernel.org> wrote:
> >
> > Some pages could be shared by several processes. (ex, libc)
> > In case of that, it's too bad to reclaim them from the beginnig.
> >
> > This patch causes VM to keep them on memory until last task
> > try to reclaim them so shared pages will be reclaimed only if
> > all of task has gone swapping out.
> >
> > This feature doesn't handle non-linear mapping on ramfs because
> > it's very time-consuming and doesn't make sure of reclaiming and
> > not common.
> 
> Against what tree does this patch apply? I've tries various trees,
> including MMOTM of 26 March, and encounter this error:
> 
>   CC      mm/ksm.o
> mm/ksm.c: In function a??try_to_unmap_ksma??:
> mm/ksm.c:1970:32: error: a??vmaa?? undeclared (first use in this function)
> mm/ksm.c:1970:32: note: each undeclared identifier is reported only
> once for each function it appears in
> make[1]: *** [mm/ksm.o] Error 1
> make: *** [mm] Error 2

I did it based on mmotm-2013-03-22-15-21 and you found build problem.
Could you apply below patch? I will fix up below in next spin.
Thanks for the testing!
