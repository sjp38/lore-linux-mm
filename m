Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id E9AAA6B003B
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 17:53:01 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id c9so1403187qcz.16
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:53:01 -0800 (PST)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id k6si41231021qej.128.2013.12.03.14.53.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 14:53:01 -0800 (PST)
Received: by mail-qa0-f44.google.com with SMTP id i13so6086205qae.3
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:53:00 -0800 (PST)
Date: Tue, 3 Dec 2013 17:52:58 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 02/23] mm/memblock: debug: don't free reserved array
 if !ARCH_DISCARD_MEMBLOCK
Message-ID: <20131203225258.GS8277@htj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-3-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386037658-3161-3-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 02, 2013 at 09:27:17PM -0500, Santosh Shilimkar wrote:
...
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

> +	/*
> +	 * Don't allow Nobootmem allocator to free reserved memory regions

Extreme nitpick: why the capitalization of "Nobootmem"?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
