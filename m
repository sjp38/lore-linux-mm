Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 86E796B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 16:25:48 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so4459802ghr.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 13:25:47 -0700 (PDT)
Date: Tue, 17 Apr 2012 13:25:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH linux-next] mm/hugetlb: fix warning in
 alloc_huge_page/dequeue_huge_page_vma
In-Reply-To: <20120417122819.7438.26117.stgit@zurg>
Message-ID: <alpine.DEB.2.00.1204171324500.10932@chino.kir.corp.google.com>
References: <20120417122819.7438.26117.stgit@zurg>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-1801852364-1334694346=:10932"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-1801852364-1334694346=:10932
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 17 Apr 2012, Konstantin Khlebnikov wrote:

> This patch fixes gcc warning (and bug?) introduced in linux-next commit cc9a6c877
> ("cpuset: mm: reduce large amounts of memory barrier related damage v3")
> 
> Local variable "page" can be uninitialized if nodemask from vma policy does not
> intersects with nodemask from cpuset. Even if it wouldn't happens it's better to
> initialize this variable explicitly than to introduce kernel oops on weird corner case.
> 
> mm/hugetlb.c: In function a??alloc_huge_pagea??:
> mm/hugetlb.c:1135:5: warning: a??pagea?? may be used uninitialized in this function
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

This isn't just in -next, it's also in Linus' tree and seems like 3.4-rc4 
material to me.
--397155492-1801852364-1334694346=:10932--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
