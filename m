Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 6A9516B0062
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 14:05:41 -0400 (EDT)
Received: by obhx4 with SMTP id x4so1642150obh.14
        for <linux-mm@kvack.org>; Wed, 19 Sep 2012 11:05:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1348039748-32111-1-git-send-email-minchan@kernel.org>
References: <1348039748-32111-1-git-send-email-minchan@kernel.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 19 Sep 2012 14:05:20 -0400
Message-ID: <CAHGf_=oSSsJEeh7eN+R6P3n0vq2h5+3DPmogpXqDiu1jJyKmpg@mail.gmail.com>
Subject: Re: [PATCH] memory-hotplug: fix zone stat mismatch
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Shaohua Li <shli@fusionio.com>

On Wed, Sep 19, 2012 at 3:29 AM, Minchan Kim <minchan@kernel.org> wrote:
> During memory-hotplug stress test, I found NR_ISOLATED_[ANON|FILE]
> are increasing so that kernel are hang out.
>
> The cause is that when we do memory-hotadd after memory-remove,
> __zone_pcp_update clear out zone's ZONE_STAT_ITEMS in setup_pageset
> without draining vm_stat_diff of all CPU.
>
> This patch fixes it.

zone_pcp_update() is called from online pages path. but IMHO,
the statistics should be drained offline path. isn't it?

thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
