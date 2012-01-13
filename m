Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E1EC46B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 21:34:22 -0500 (EST)
Message-ID: <4F0F987E.1080001@freescale.com>
Date: Fri, 13 Jan 2012 10:35:42 +0800
From: Huang Shijie <b32955@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/compaction : do optimazition when the migration
 scanner gets no page
References: <1326347222-9980-1-git-send-email-b32955@freescale.com> <20120112080311.GA30634@barrios-desktop.redhat.com> <20120112114835.GI4118@suse.de> <20120113005026.GA2614@barrios-desktop.redhat.com>
In-Reply-To: <20120113005026.GA2614@barrios-desktop.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org

Hi,
> I think simple patch is returning "return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;"
> It's very clear and readable, I think.
> In this patch, what's the problem you think?
>
sorry for the wrong thread, please read the following thread:
http://marc.info/?l=linux-mm&m=132532266130861&w=2

Best Regards
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
