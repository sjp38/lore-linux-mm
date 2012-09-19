Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id F3F416B002B
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:17:47 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so3612378pbb.14
        for <linux-mm@kvack.org>; Wed, 19 Sep 2012 13:17:47 -0700 (PDT)
Date: Thu, 20 Sep 2012 05:17:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] memory-hotplug: fix zone stat mismatch
Message-ID: <20120919201738.GA2425@barrios>
References: <1348039748-32111-1-git-send-email-minchan@kernel.org>
 <CAHGf_=oSSsJEeh7eN+R6P3n0vq2h5+3DPmogpXqDiu1jJyKmpg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=oSSsJEeh7eN+R6P3n0vq2h5+3DPmogpXqDiu1jJyKmpg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Shaohua Li <shli@fusionio.com>

Hi KOSAKI,

On Wed, Sep 19, 2012 at 02:05:20PM -0400, KOSAKI Motohiro wrote:
> On Wed, Sep 19, 2012 at 3:29 AM, Minchan Kim <minchan@kernel.org> wrote:
> > During memory-hotplug stress test, I found NR_ISOLATED_[ANON|FILE]
> > are increasing so that kernel are hang out.
> >
> > The cause is that when we do memory-hotadd after memory-remove,
> > __zone_pcp_update clear out zone's ZONE_STAT_ITEMS in setup_pageset
> > without draining vm_stat_diff of all CPU.
> >
> > This patch fixes it.
> 
> zone_pcp_update() is called from online pages path. but IMHO,
> the statistics should be drained offline path. isn't it?

It isn't necessary because statistics is right until we reset it to zero
in online path.
Do you have something on your mind that we have to drain it in offline path?

> 
> thanks.

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
