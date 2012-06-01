Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 189506B0099
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 16:27:02 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4177786dak.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 13:27:01 -0700 (PDT)
Message-ID: <4FC92591.1070401@gmail.com>
Date: Fri, 01 Jun 2012 16:26:57 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] proc: add ARCH_PFN_OFFSET info to /proc/meminfo
References: <201206011854.17399.b.zolnierkie@samsung.com>
In-Reply-To: <201206011854.17399.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>, kosaki.motohiro@gmail.com

(6/1/12 12:54 PM), Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> Subject: [PATCH] proc: add ARCH_PFN_OFFSET info to /proc/meminfo
>
> ARCH_PFN_OFFSET is needed for user-space to use together with
> /proc/kpage[count,flags] interfaces.
>
> Cc: Matt Mackall<mpm@selenic.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park<kyungmin.park@samsung.com>
> ---
>   fs/proc/meminfo.c |    4 ++++
>   1 file changed, 4 insertions(+)
>
> Index: b/fs/proc/meminfo.c
> ===================================================================
> --- a/fs/proc/meminfo.c	2012-05-31 16:53:11.589706973 +0200
> +++ b/fs/proc/meminfo.c	2012-05-31 17:03:17.719237120 +0200
> @@ -168,6 +168,10 @@ static int meminfo_proc_show(struct seq_
>
>   	hugetlb_report_meminfo(m);
>
> +	seq_printf(m,
> +		"ArchPFNOffset:    %6lu\n",
> +		ARCH_PFN_OFFSET);
> +
>   	arch_report_meminfo(m);

NAK.

arch specific report should use arch_report_meminfo().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
