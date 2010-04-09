Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AF6106B01FB
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 23:20:44 -0400 (EDT)
Message-ID: <4BBE9D58.2010602@cn.fujitsu.com>
Date: Fri, 09 Apr 2010 11:22:00 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fix cgroup procs documentation
References: <20100409121143.9610dc8f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100409121143.9610dc8f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> 2.6.33's Documentation has the same wrong information. So, I CC'ed to stable.
> If people believe this information, they'll usr cgroup.procs file and will
> see cgroup doesn'w work as expected.
> The patch itself is against -mm.
> 
> ==
> Writing to cgroup.procs is not supported now.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/cgroups.txt |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> Index: mmotm-temp/Documentation/cgroups/cgroups.txt
> ===================================================================
> --- mmotm-temp.orig/Documentation/cgroups/cgroups.txt
> +++ mmotm-temp/Documentation/cgroups/cgroups.txt
> @@ -235,8 +235,7 @@ containing the following files describin
>   - cgroup.procs: list of tgids in the cgroup.  This list is not
>     guaranteed to be sorted or free of duplicate tgids, and userspace
>     should sort/uniquify the list if this property is required.
> -   Writing a tgid into this file moves all threads with that tgid into
> -   this cgroup.
> +   This is a read-only file, now.

I think the better wording is "for now". :)

>   - notify_on_release flag: run the release agent on exit?
>   - release_agent: the path to use for release notifications (this file
>     exists in the top cgroup only)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
