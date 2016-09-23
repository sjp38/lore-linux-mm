Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD016B0289
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 15:23:53 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t204so264305142ywt.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 12:23:53 -0700 (PDT)
Received: from mail-yb0-x22a.google.com (mail-yb0-x22a.google.com. [2607:f8b0:4002:c09::22a])
        by mx.google.com with ESMTPS id m138si3380562ywd.385.2016.09.23.12.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 12:23:52 -0700 (PDT)
Received: by mail-yb0-x22a.google.com with SMTP id u125so70985428ybg.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 12:23:52 -0700 (PDT)
Date: Fri, 23 Sep 2016 15:23:51 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] mm/percpu.c: correct max_distance calculation for
 pcpu_embed_first_chunk()
Message-ID: <20160923192351.GE31387@htj.duckdns.org>
References: <7180d3c9-45d3-ffd2-cf8c-0d925f888a4d@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7180d3c9-45d3-ffd2-cf8c-0d925f888a4d@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, zijun_hu@htc.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cl@linux.com

On Sat, Sep 24, 2016 at 02:20:24AM +0800, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> correct max_distance from (base of the highest group + ai->unit_size)
> to (base of the highest group + the group size)
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>

Nacked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
