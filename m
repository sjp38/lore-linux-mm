Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id E903E6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 17:14:31 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id a108so2084306qge.18
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:14:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u89si12500991qga.83.2014.04.18.14.14.31
        for <linux-mm@kvack.org>;
        Fri, 18 Apr 2014 14:14:31 -0700 (PDT)
Message-ID: <535195AC.1070702@redhat.com>
Date: Fri, 18 Apr 2014 17:14:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/swap: cleanup *lru_cache_add* functions
References: <1397835565-6411-1-git-send-email-nasa4836@gmail.com>
In-Reply-To: <1397835565-6411-1-git-send-email-nasa4836@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>, akpm@linux-foundation.org, minchan@kernel.org, hannes@cmpxchg.org, shli@kernel.org, bob.liu@oracle.com, sjenning@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, aquini@redhat.com, mgorman@suse.de, aarcange@redhat.com, khalid.aziz@oracle.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/18/2014 11:39 AM, Jianyu Zhan wrote:
> Hi, Christoph Hellwig,
> 
>> There are no modular users of lru_cache_add, so please don't needlessly
>> export it.
> 
> yep, I re-checked and found there is no module user of neither 
> lru_cache_add() nor lru_cache_add_anon(), so don't export it.
> 
> Here is the renewed patch:
> ---
> 
> In mm/swap.c, __lru_cache_add() is exported, but actually there are
> no users outside this file. However, lru_cache_add() is supposed to
> be used by vfs, or whatever others, but it is not exported.
> 
> This patch unexports __lru_cache_add(), and makes it static.
> It also exports lru_cache_add_file(), as it is use by cifs, which
> be loaded as module.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
