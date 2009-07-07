Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 445C56B005A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:45:29 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CE5AF82C5FC
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 13:05:34 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TrrCxBconTJ1 for <linux-mm@kvack.org>;
	Tue,  7 Jul 2009 13:05:34 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A799D82C607
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 13:05:16 -0400 (EDT)
Date: Tue, 7 Jul 2009 12:46:54 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <20090705182451.08FF.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907071238570.5124@gentwo.org>
References: <20090705181400.08F1.A69D9226@jp.fujitsu.com> <20090705182451.08FF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 2009, KOSAKI Motohiro wrote:

>  mm/vmstat.c            |    2 +-
>  6 files changed, 14 insertions(+), 3 deletions(-)
>
> Index: b/fs/proc/meminfo.c
> ===================================================================
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -65,6 +65,7 @@ static int meminfo_proc_show(struct seq_
>  		"Active(file):   %8lu kB\n"
>  		"Inactive(file): %8lu kB\n"
>  		"Unevictable:    %8lu kB\n"
> +		"IsolatedPages:  %8lu kB\n"

Why is it called isolatedpages when we display the amount of memory in
kilobytes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
