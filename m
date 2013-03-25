Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id D6F546B0002
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 22:28:05 -0400 (EDT)
Message-ID: <514FB24F.8080104@cn.fujitsu.com>
Date: Mon, 25 Mar 2013 10:11:27 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
References: <20130318155619.GA18828@sgi.com> <20130321105516.GC18484@gmail.com> <alpine.DEB.2.02.1303211139110.3775@chino.kir.corp.google.com> <20130322072532.GC10608@gmail.com> <20130323152948.GA3036@sgi.com> <CAE9FiQUjVRUs02-ymmtO+5+SgqTWK8Ae6jJwD08uRbgR=eLJgw@mail.gmail.com>
In-Reply-To: <CAE9FiQUjVRUs02-ymmtO+5+SgqTWK8Ae6jJwD08uRbgR=eLJgw@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>, Russ Anderson <rja@sgi.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com



On 03/24/2013 04:37 AM, Yinghai Lu wrote:
> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
> +			 unsigned long *start_pfn, unsigned long *end_pfn)
> +{
> +	struct memblock_type *type = &memblock.memory;
> +	int mid = memblock_search(type, (phys_addr_t)pfn << PAGE_SHIFT);

I'm really eager to see how much time can we save using binary search compared to
linear search in this case :)

(quote)
> A 4 TB (single rack) UV1 system takes 512 seconds to get through
> the zone code.  This performance optimization reduces the time
> by 189 seconds, a 36% improvement.
>
> A 2 TB (single rack) UV2 system goes from 212.7 seconds to 99.8 seconds,
> a 112.9 second (53%) reduction.
(quote)

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
