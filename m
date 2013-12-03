Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f45.google.com (mail-qe0-f45.google.com [209.85.128.45])
	by kanga.kvack.org (Postfix) with ESMTP id 580BD6B003C
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 17:53:51 -0500 (EST)
Received: by mail-qe0-f45.google.com with SMTP id 6so15603038qea.18
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:53:51 -0800 (PST)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id f1si1993561qar.36.2013.12.03.14.53.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 14:53:50 -0800 (PST)
Received: by mail-qc0-f176.google.com with SMTP id i8so2750733qcq.35
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:53:49 -0800 (PST)
Date: Tue, 3 Dec 2013 17:53:46 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 03/23] mm/bootmem: remove duplicated declaration of
 __free_pages_bootmem()
Message-ID: <20131203225346.GT8277@htj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-4-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386037658-3161-4-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 02, 2013 at 09:27:18PM -0500, Santosh Shilimkar wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> 
> The __free_pages_bootmem is used internally by MM core and
> already defined in internal.h. So, remove duplicated declaration.
> 
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
