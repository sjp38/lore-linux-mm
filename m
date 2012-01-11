Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id F40566B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 07:14:53 -0500 (EST)
Received: by wics10 with SMTP id s10so433167wic.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 04:14:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120110165743.GE4118@suse.de>
References: <CAJd=RBDAoNt=TZWhNeLs0MaCJ_ormEp=ya55-PA+B0BAxfGbbQ@mail.gmail.com>
	<20120110094026.GB4118@suse.de>
	<CAJd=RBBNK6P=Kq09G88UDEsiU8KUPiko5WTfLgQqKzry8tVH5A@mail.gmail.com>
	<20120110165743.GE4118@suse.de>
Date: Wed, 11 Jan 2012 20:14:52 +0800
Message-ID: <CAJd=RBAMn0Zi49iukLfV1S3je08OCqFv3nu=CZG1WTNyom7nig@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: no change of reclaim mode if unevictable page encountered
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 11, 2012 at 12:57 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> When I said it needed more justification, I meant that you need to show
> a workload or usecase that suffers as a result of reset_reclaim_mode
> being called here. I explained already that the reset errs on the
> side of caution by making reclaim work less.
>
> You need to describe what problem your workload is suffering from and
> why this patch fixes it.
>
Got and thanks for review /Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
