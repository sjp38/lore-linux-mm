Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 088466B0011
	for <linux-mm@kvack.org>; Sun, 22 May 2011 19:31:39 -0400 (EDT)
Received: by qyk30 with SMTP id 30so3732960qyk.14
        for <linux-mm@kvack.org>; Sun, 22 May 2011 16:31:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
Date: Mon, 23 May 2011 08:31:35 +0900
Message-ID: <BANLkTi=XRo-gwdN0aLVFRMQa+DvCpXO7Rg@mail.gmail.com>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem fix
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, May 18, 2011 at 3:24 AM, Hugh Dickins <hughd@google.com> wrote:
> mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
> target mm, not for current mm (but of course they're usually the same).
>
> We don't know the target mm in shmem_getpage(), so do it at the outer
> level in shmem_fault(); and it's easier to follow if we move the
> count_vm_event(PGMAJFAULT) there too.
>
> Hah, it was using __count_vm_event() before, sneaking that update into
> the unpreemptible section under info->lock: well, it comes to the same
> on x86 at least, and I still think it's best to keep these together.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I am okay if memcg maintainer knew behavior change of shmem fault accounting.
What I want was let memcg maintainer know slight behavior change.

Thanks, Hugh.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
