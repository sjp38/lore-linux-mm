Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B94F6B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 15:57:32 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id v76so87179897ywg.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 12:57:32 -0800 (PST)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id p66si4315999ywp.377.2017.03.06.12.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 12:57:31 -0800 (PST)
Received: by mail-yw0-x243.google.com with SMTP id p77so4711749ywg.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 12:57:31 -0800 (PST)
Date: Mon, 6 Mar 2017 15:57:29 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] percpu: remove unused chunk_alloc parameter from
 pcpu_get_pages()
Message-ID: <20170306205729.GG26127@htj.duckdns.org>
References: <20170225205926.23431-1-tahsin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170225205926.23431-1-tahsin@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Feb 25, 2017 at 12:59:26PM -0800, Tahsin Erdogan wrote:
> pcpu_get_pages() doesn't use chunk_alloc parameter, remove it.
> 
> Fixes: fbbb7f4e149f ("percpu: remove the usage of separate populated bitmap in percpu-vm")
> Signed-off-by: Tahsin Erdogan <tahsin@google.com>

Applied to wq/for-4.11-fixes.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
