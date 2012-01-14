Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id C5F396B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 21:10:58 -0500 (EST)
Received: by yenm10 with SMTP id m10so651968yen.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 18:10:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120113112832.GR4118@suse.de>
References: <1325818201-1865-1-git-send-email-b32955@freescale.com>
	<4F0E76BE.1070806@freescale.com>
	<20120112120530.GJ4118@suse.de>
	<4F0F9770.10004@freescale.com>
	<20120113112832.GR4118@suse.de>
Date: Sat, 14 Jan 2012 10:10:57 +0800
Message-ID: <CAMiH66F0Oow6jvXuwr0+6s+0wOV4nvu=_chfe8_NJhpacZE80A@mail.gmail.com>
Subject: Re: [PATCH v2] mm/compaction : check the watermark when cc->order is -1
From: Huang Shijie <shijie8@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Huang Shijie <b32955@freescale.com>, akpm@linux-foundation.org, linux-mm@kvack.org

hi,
> When I glanced at this first, I missed that you altered the watermark
> check as well. When I said "Code wise the patch is fine", I was wrong.
> Compaction works in units of pageblocks and the watermark check
> is necessary. Reducing it to COMPACT_CLUSTER_MAX*2 leads to the
> possibility of compaction via /proc causing livelocks in low memory
> situations depending on the value of min_free_kbytes.

ok, thanks a lot for the explanation.

Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
