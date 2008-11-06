Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA62qiDM015882
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 6 Nov 2008 11:52:44 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E03AE45DE4D
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:52:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BC82D45DE3E
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:52:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A5CAD1DB803C
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:52:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 64C311DB803A
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:52:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 7/7] cpu alloc: page allocator conversion
In-Reply-To: <20081105231650.526116017@quilx.com>
References: <20081105231634.133252042@quilx.com> <20081105231650.526116017@quilx.com>
Message-Id: <20081106115113.0D38.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  6 Nov 2008 11:52:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

> +#ifdef CONFIG_SMP
>  static int __cpuinit pageset_cpuup_callback(struct notifier_block *nfb,
>  		unsigned long action,
>  		void *hcpu)
> @@ -2800,14 +2746,7 @@
>  	switch (action) {
>  	case CPU_UP_PREPARE:
>  	case CPU_UP_PREPARE_FROZEN:
> -		if (process_zones(cpu))
> -			ret = NOTIFY_BAD;
> -		break;
> -	case CPU_UP_CANCELED:
> -	case CPU_UP_CANCELED_FROZEN:
> -	case CPU_DEAD:
> -	case CPU_DEAD_FROZEN:
> -		free_zone_pagesets(cpu);
> +		process_zones(cpu);
>  		break;

Why do you drop cpu unplug code?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
