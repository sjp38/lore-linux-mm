Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 4970F6B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 12:50:20 -0400 (EDT)
Received: by mail-ob0-f179.google.com with SMTP id wn1so1300801obc.24
        for <linux-mm@kvack.org>; Fri, 13 Sep 2013 09:50:19 -0700 (PDT)
Message-ID: <5233424A.2050704@gmail.com>
Date: Fri, 13 Sep 2013 12:50:18 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <52312EC1.8080300@asianux.com> <523205A0.1000102@gmail.com> <5232773E.8090007@asianux.com>
In-Reply-To: <5232773E.8090007@asianux.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

> ---
>   mm/shmem.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 8612a95..3f81120 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -890,7 +890,7 @@ static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>   	if (!mpol || mpol->mode == MPOL_DEFAULT)
>   		return;		/* show nothing */
>
> -	mpol_to_str(buffer, sizeof(buffer), mpol);
> +	VM_BUG_ON(mpol_to_str(buffer, sizeof(buffer), mpol) < 0);

NAK. VM_BUG_ON is a kind of assertion. It erase the contents if CONFIG_DEBUG_VM not set.
An argument of assertion should not have any side effect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
