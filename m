Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id CC8216B0253
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 10:40:19 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so20174405qkc.3
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 07:40:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j92si8072537qga.87.2015.09.18.07.40.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 07:40:18 -0700 (PDT)
Message-ID: <55FC224F.2020308@redhat.com>
Date: Fri, 18 Sep 2015 10:40:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] doc: add information about max_ptes_swap
References: <1442525698-22598-1-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1442525698-22598-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kirill.shutemov@linux.intel.com, dave@stgolabs.net, denc716@gmail.com, ldufour@linux.vnet.ibm.com, sasha.levin@oracle.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org

On 09/17/2015 05:34 PM, Ebru Akagunduz wrote:
> max_ptes_swap specifies how many pages can be brought in from
> swap when collapsing a group of pages into a transparent huge page.
> 
> /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
> 
> A higher value can cause excessive swap IO and waste
> memory. A lower value can prevent THPs from being
> collapsed, resulting fewer pages being collapsed into
> THPs, and lower memory access performance.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
