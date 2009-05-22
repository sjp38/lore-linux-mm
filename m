Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D792B6B0062
	for <linux-mm@kvack.org>; Fri, 22 May 2009 04:18:55 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4M8JB1X006241
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 May 2009 17:19:11 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C09645DE4F
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:19:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3205D45DE51
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:19:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A797DE08002
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:19:10 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A5381DB805B
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:19:10 +0900 (JST)
Date: Fri, 22 May 2009 17:17:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove forward declaration from sched.h
Message-Id: <20090522171737.e9916d1b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A1645D4.5010001@cn.fujitsu.com>
References: <4A1645D4.5010001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 May 2009 14:27:32 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> This forward declaration seems pointless.
> 
> compile tested.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Nice catch. (but I don't know why this sneaked into..)
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  sched.h |    1 -
>  1 file changed, 1 deletion(-)
> 
> --- a/include/linux/sched.h	2009-05-22 13:43:01.000000000 +0800
> +++ b/include/linux/sched.h	2009-05-22 13:38:59.000000000 +0800
> @@ -93,7 +93,6 @@ struct sched_param {
>  
>  #include <asm/processor.h>
>  
> -struct mem_cgroup;
>  struct exec_domain;
>  struct futex_pi_state;
>  struct robust_list_head;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
