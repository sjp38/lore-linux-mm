Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id ACB866B005A
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 03:29:53 -0500 (EST)
Message-ID: <4F0E9A4F.8040004@freescale.com>
Date: Thu, 12 Jan 2012 16:31:11 +0800
From: Huang Shijie <b32955@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/compaction : check the watermark when cc->order
 is -1
References: <1325818201-1865-1-git-send-email-b32955@freescale.com> <20120112081506.GB30634@barrios-desktop.redhat.com>
In-Reply-To: <20120112081506.GB30634@barrios-desktop.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org, shijie8@gmail.com

Hi,
> It seems this patch is useful but I can't parse your this sentense.
> Could you elaborate on it?
sorry for my poor english.
> We should know about exactly why order == -1 is COMPACT_CLUSTER_MAX * 2 and other case
> 2UL<<  order. If you write down description more clear, it will help.
>
ok.

thanks

Huang Shijie


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
