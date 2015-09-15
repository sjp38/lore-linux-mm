Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0D71A6B025A
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:59:47 -0400 (EDT)
Received: by lamp12 with SMTP id p12so100756408lam.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:59:46 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id c11si12444748lbq.1.2015.09.15.00.59.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 00:59:45 -0700 (PDT)
Date: Tue, 15 Sep 2015 10:59:24 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH V2  1/2] mm: Replace nr_node_ids for loop with
 for_each_node in list lru
Message-ID: <20150915075924.GD16220@esperanza>
References: <1442282917-16893-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <1442282917-16893-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1442282917-16893-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org, nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 15, 2015 at 07:38:36AM +0530, Raghavendra K T wrote:
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
> [ Take memcg_aware check outside for_each loop: Vldimir]
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
