Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 602852802C9
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 20:16:45 -0400 (EDT)
Received: by igvi1 with SMTP id i1so2293742igv.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:16:45 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id is9si222832igb.5.2015.07.15.17.16.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 17:16:44 -0700 (PDT)
Received: by iggp10 with SMTP id p10so2312663igg.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:16:44 -0700 (PDT)
Date: Wed, 15 Jul 2015 17:16:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V3] mm/page: refine the calculation of highest possible
 node id
In-Reply-To: <1436588248-25546-1-git-send-email-weiyang@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1507151716330.9230@chino.kir.corp.google.com>
References: <1436584096-7016-1-git-send-email-weiyang@linux.vnet.ibm.com> <1436588248-25546-1-git-send-email-weiyang@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

On Sat, 11 Jul 2015, Wei Yang wrote:

> nr_node_ids records the highest possible node id, which is calculated by
> scanning the bitmap node_states[N_POSSIBLE]. Current implementation scan
> the bitmap from the beginning, which will scan the whole bitmap.
> 
> This patch reverse the order by scanning from the end with find_last_bit().
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Tejun Heo <tj@kernel.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
