Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC556B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 22:15:52 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so160554825pad.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 19:15:51 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id lc9si27732248pbc.107.2015.09.14.19.15.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Sep 2015 19:15:51 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 15 Sep 2015 07:45:47 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 750BFE0059
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:45:16 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8F2FjLA48234608
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:45:45 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8F2FiDV026394
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:45:44 +0530
Message-ID: <55F77FB6.7020806@linux.vnet.ibm.com>
Date: Tue, 15 Sep 2015 07:47:26 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2  1/2] mm: Replace nr_node_ids for loop with for_each_node
 in list lru
References: <1442282917-16893-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1442282917-16893-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
In-Reply-To: <1442282917-16893-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org, nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/15/2015 07:38 AM, Raghavendra K T wrote:
> The functions used in the patch are in slowpath, which gets called
> whenever alloc_super is called during mounts.
>
> Though this should not make difference for the architectures with
> sequential numa node ids, for the powerpc which can potentially have
> sparse node ids (for e.g., 4 node system having numa ids, 0,1,16,17
> is common), this patch saves some unnecessary allocations for
> non existing numa nodes.
>
> Even without that saving, perhaps patch makes code more readable.
>
> [ Take memcg_aware check outside for_each loop: Vladimir]
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> ---

Sorry that I had misspelled Vladimir above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
