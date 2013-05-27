Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 636FE6B0036
	for <linux-mm@kvack.org>; Mon, 27 May 2013 12:24:59 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id l20so8767803oag.23
        for <linux-mm@kvack.org>; Mon, 27 May 2013 09:24:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1369668984-2787-1-git-send-email-dserrg@gmail.com>
References: <1369668984-2787-1-git-send-email-dserrg@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 27 May 2013 12:24:38 -0400
Message-ID: <CAHGf_=pyEP=zJ80HSKAojymSmW=S1s+1QFN663OXD8RtonLVmA@mail.gmail.com>
Subject: Re: [PATCH][trivial] memcg: Kconfig info update
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Dyasly <dserrg@gmail.com>
Cc: cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, May 27, 2013 at 11:36 AM, Sergey Dyasly <dserrg@gmail.com> wrote:
> Now there are only 2 members in struct page_cgroup.
> Update config MEMCG description accordingly.
>
> Signed-off-by: Sergey Dyasly <dserrg@gmail.com>
> ---
>  init/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/init/Kconfig b/init/Kconfig
> index 9d3a788..16d1502 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -876,7 +876,7 @@ config MEMCG
>
>           Note that setting this option increases fixed memory overhead
>           associated with each page of memory in the system. By this,
> -         20(40)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
> +         8(16)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
>           usage tracking struct at boot. Total amount of this is printed out
>           at boot.

Yes, kernel developers often foget to update documentations. Nice catch!

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
