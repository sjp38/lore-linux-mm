Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E03706B0032
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 16:26:51 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 16 Sep 2013 16:26:50 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A094E6E8059
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 16:26:10 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8GKQANT51052712
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 20:26:10 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8GKQ9OJ014076
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 17:26:09 -0300
Message-ID: <5237695F.6010501@linux.vnet.ibm.com>
Date: Mon, 16 Sep 2013 13:26:07 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mempolicy: use NUMA_NO_NODE
References: <5236FF32.60503@huawei.com>
In-Reply-To: <5236FF32.60503@huawei.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> @@ -1802,11 +1802,11 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
>
>   /*
>    * Return the bit number of a random bit set in the nodemask.
> - * (returns -1 if nodemask is empty)
> + * (returns NUMA_NO_NOD if nodemask is empty)

s/NUMA_NO_NOD/NUMA_NO_NODE/

>    */
>   int node_random(const nodemask_t *maskp)
>   {
> -	int w, bit = -1;
> +	int w, bit = NUMA_NO_NODE;
>
>   	w = nodes_weight(*maskp);
>   	if (w)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
