Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9264E6B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:57:31 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so3676714pab.32
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:57:31 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id bq5si6372418pbb.78.2014.02.07.12.57.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 12:57:30 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so3654864pab.18
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:57:30 -0800 (PST)
Date: Fri, 7 Feb 2014 12:57:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 8/9] mm: Mark function as static in nobootmem.c
In-Reply-To: <bc0e22c79ac3af48f50a81ddb5e449018685ac4d.1391167128.git.rashika.kheria@gmail.com>
Message-ID: <alpine.DEB.2.02.1402071257160.4212@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <bc0e22c79ac3af48f50a81ddb5e449018685ac4d.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1527980306-1391806649=:4212"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jiang Liu <jiang.liu@huawei.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, josh@joshtriplett.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1527980306-1391806649=:4212
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Fri, 7 Feb 2014, Rashika Kheria wrote:

> Mark function as static in nobootmem.c because it is not used outside
> this file.
> 
> This eliminates the following warning in mm/nobootmem.c:
> mm/nobootmem.c:324:15: warning: no previous prototype for a??___alloc_bootmem_nodea?? [-Wmissing-prototypes]
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

Acked-by: David Rientjes <rientjes@google.com>
--531381512-1527980306-1391806649=:4212--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
