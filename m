Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5122D6B0062
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 17:58:20 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id i17so2730232qcy.37
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:58:20 -0800 (PST)
Received: from mail-qe0-x22c.google.com (mail-qe0-x22c.google.com [2607:f8b0:400d:c02::22c])
        by mx.google.com with ESMTPS id c9si3020116qab.12.2013.12.03.14.58.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 14:58:18 -0800 (PST)
Received: by mail-qe0-f44.google.com with SMTP id nd7so14730530qeb.17
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:58:18 -0800 (PST)
Date: Tue, 3 Dec 2013 17:58:15 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 07/23] mm/memblock: drop WARN and use SMP_CACHE_BYTES
 as a default alignment
Message-ID: <20131203225815.GW8277@htj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-8-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386037658-3161-8-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 02, 2013 at 09:27:22PM -0500, Santosh Shilimkar wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> 
> drop WARN and use SMP_CACHE_BYTES as a default alignment in
> memblock_alloc_base_nid() as recommended by Tejun Heo in
> https://lkml.org/lkml/2013/10/13/117.

Can you please add description on why this change is being made?  This
is in preparation of common alloc interface, right?  The patch
description is kinda out-of-blue.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
