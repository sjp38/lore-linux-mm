Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D7206B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 20:05:24 -0400 (EDT)
Date: Wed, 16 Sep 2009 01:04:39 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Isolated(anon) and Isolated(file)
In-Reply-To: <20090915114742.DB79.A69D9226@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0909160047480.4234@sister.anvils>
References: <Pine.LNX.4.64.0909132011550.28745@sister.anvils>
 <20090915114742.DB79.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Sep 2009, KOSAKI Motohiro wrote:
> From 7aa6fa2b76ff5d063b8bfa4a3af38c39b9396fd5 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 15 Sep 2009 10:16:51 +0900
> Subject: [PATCH] Kill Isolated field in /proc/meminfo
> 
> Hugh Dickins pointed out Isolated field dislpay 0kB at almost time.
> It is only increased at heavy memory pressure case.
> 
> So, if the system haven't get memory pressure, this field isn't useful.
> And now, we have two alternative way, /sys/device/system/node/node{n}/meminfo
> and /prov/vmstat. Then, it can be removed.
> 
> Reported-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

I should be overjoyed that you agree to hide the Isolateds from my sight:
thank you.  But in fact I'm a little depressed, now you've reminded me of
almost-the-same-but-annoyingly-different /sys/devices/unmemorable/meminfo.

Oh well, since I never see it (I'd need some nodes), I guess I don't
even need to turn a blind eye to it; and it already contains other
stuff I objected to in /proc/meminfo.

I still think your Isolateds make most sense in the OOM display;
and yes, they are there in /proc/vmstat, that's good too.

> ---
>  fs/proc/meminfo.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 7d46c2e..c7bff4f 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -65,8 +65,6 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  		"Active(file):   %8lu kB\n"
>  		"Inactive(file): %8lu kB\n"
>  		"Unevictable:    %8lu kB\n"
> -		"Isolated(anon): %8lu kB\n"
> -		"Isolated(file): %8lu kB\n"
>  		"Mlocked:        %8lu kB\n"
>  #ifdef CONFIG_HIGHMEM
>  		"HighTotal:      %8lu kB\n"
> @@ -116,8 +114,6 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  		K(pages[LRU_ACTIVE_FILE]),
>  		K(pages[LRU_INACTIVE_FILE]),
>  		K(pages[LRU_UNEVICTABLE]),
> -		K(global_page_state(NR_ISOLATED_ANON)),
> -		K(global_page_state(NR_ISOLATED_FILE)),
>  		K(global_page_state(NR_MLOCK)),
>  #ifdef CONFIG_HIGHMEM
>  		K(i.totalhigh),
> -- 
> 1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
