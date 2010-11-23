Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BA6556B0085
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:16:59 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN7Gu1E018386
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 16:16:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F18445DE70
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0467245DE6F
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C61881DB803F
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8126E1DB803E
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][V2] nommu: yield CPU while disposing VM
In-Reply-To: <1289912805-4143-1-git-send-email-steve@digidescorp.com>
References: <1289912805-4143-1-git-send-email-steve@digidescorp.com>
Message-Id: <20101122100830.E22A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 16:16:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Steven J. Magnani" <steve@digidescorp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, stable@kernel.org, linux-kernel@vger.kernel.org, gerg@snapgear.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> Depending on processor speed, page size, and the amount of memory a process
> is allowed to amass, cleanup of a large VM may freeze the system for many
> seconds. This can result in a watchdog timeout.
> 
> Make sure other tasks receive some service when cleaning up large VMs.
> 
> Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
> ---
> diff -uprN a/mm/nommu.c b/mm/nommu.c
> --- a/mm/nommu.c	2010-11-15 07:53:45.000000000 -0600
> +++ b/mm/nommu.c	2010-11-15 07:57:13.000000000 -0600
> @@ -1668,6 +1668,7 @@ void exit_mmap(struct mm_struct *mm)
>  		mm->mmap = vma->vm_next;
>  		delete_vma_from_mm(vma);
>  		delete_vma(mm, vma);
> +		cond_resched();
>  	}
>  
>  	kleave("");
> 

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
