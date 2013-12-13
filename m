Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id EAACB6B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 16:21:38 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id cm18so1182306qab.4
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 13:21:38 -0800 (PST)
Received: from mail-qe0-x22e.google.com (mail-qe0-x22e.google.com [2607:f8b0:400d:c02::22e])
        by mx.google.com with ESMTPS id nm5si3526518qeb.50.2013.12.13.13.21.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 13:21:38 -0800 (PST)
Received: by mail-qe0-f46.google.com with SMTP id a11so2046319qen.5
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 13:21:37 -0800 (PST)
Date: Fri, 13 Dec 2013 16:21:34 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 05/23] mm/memblock: drop WARN and use SMP_CACHE_BYTES
 as a default alignment
Message-ID: <20131213212134.GJ27070@htj.dyndns.org>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
 <1386625856-12942-6-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386625856-12942-6-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 09, 2013 at 04:50:38PM -0500, Santosh Shilimkar wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> 
> Don't produce warning and interpret 0 as "default align" equal to
> SMP_CACHE_BYTES in case if caller of memblock_alloc_base_nid() doesn't
> specify alignment for the block (align == 0).
> 
> This is done in preparation of introducing common memblock alloc
> interface to make code behavior consistent. More details are
> in below thread :
> 	https://lkml.org/lkml/2013/10/13/117.
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
