Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f44.google.com (mail-qe0-f44.google.com [209.85.128.44])
	by kanga.kvack.org (Postfix) with ESMTP id EF3B66B0035
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 16:22:33 -0500 (EST)
Received: by mail-qe0-f44.google.com with SMTP id nd7so2117066qeb.31
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 13:22:33 -0800 (PST)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id j7si3523906qab.55.2013.12.13.13.22.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 13:22:33 -0800 (PST)
Received: by mail-qa0-f48.google.com with SMTP id w5so1183784qac.14
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 13:22:32 -0800 (PST)
Date: Fri, 13 Dec 2013 16:22:29 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 06/23] mm/memblock: reorder parameters of
 memblock_find_in_range_node
Message-ID: <20131213212229.GK27070@htj.dyndns.org>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
 <1386625856-12942-7-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386625856-12942-7-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 09, 2013 at 04:50:39PM -0500, Santosh Shilimkar wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> 
> Reorder parameters of memblock_find_in_range_node to be consistent
> with other memblock APIs.
> 
> The change was suggested by Tejun Heo <tj@kernel.org>.
> 
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
