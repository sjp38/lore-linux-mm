Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 03B792802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 20:10:56 -0400 (EDT)
Received: by igcqs7 with SMTP id qs7so1931800igc.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:10:55 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id bx19si185096igb.63.2015.07.15.17.10.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 17:10:55 -0700 (PDT)
Received: by ietj16 with SMTP id j16so45335109iet.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:10:55 -0700 (PDT)
Date: Wed, 15 Jul 2015 17:10:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/page: remove unused variable of
 free_area_init_core()
In-Reply-To: <1436584368-7639-1-git-send-email-weiyang@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1507151710430.9230@chino.kir.corp.google.com>
References: <1436584368-7639-1-git-send-email-weiyang@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

On Sat, 11 Jul 2015, Wei Yang wrote:

> commit <febd5949e134> ("mm/memory hotplug: init the zone's size when
> calculating node totalpages") refine the function free_area_init_core().
> After doing so, these two parameter is not used anymore.
> 
> This patch removes these two parameters.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> CC: Gu Zheng <guz.fnst@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
