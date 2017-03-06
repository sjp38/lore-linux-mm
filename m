Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7D316B0388
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 15:56:14 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id 2so318345698ywn.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 12:56:14 -0800 (PST)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id h13si4309913ywa.354.2017.03.06.12.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 12:56:13 -0800 (PST)
Received: by mail-yw0-x241.google.com with SMTP id p77so4708262ywg.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 12:56:13 -0800 (PST)
Date: Mon, 6 Mar 2017 15:56:12 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] percpu: acquire pcpu_lock when updating
 pcpu_nr_empty_pop_pages
Message-ID: <20170306205612.GF26127@htj.duckdns.org>
References: <20170225210019.23610-1-tahsin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170225210019.23610-1-tahsin@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Feb 25, 2017 at 01:00:19PM -0800, Tahsin Erdogan wrote:
> Update to pcpu_nr_empty_pop_pages in pcpu_alloc() is currently done
> without holding pcpu_lock. This can lead to bad updates to the variable.
> Add missing lock calls.
> 
> Fixes: b539b87fed37 ("percpu: implmeent pcpu_nr_empty_pop_pages and chunk->nr_populated")
> Signed-off-by: Tahsin Erdogan <tahsin@google.com>

Applied to percpu/for-4.11-fixes w/ stable cc'd.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
