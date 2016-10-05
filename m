Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id E05C66B0038
	for <linux-mm@kvack.org>; Wed,  5 Oct 2016 11:56:35 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id u124so62811288ywg.2
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 08:56:35 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id t42si3694968ybi.294.2016.10.05.08.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Oct 2016 08:56:00 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id r132so6216166ywg.3
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 08:56:00 -0700 (PDT)
Date: Wed, 5 Oct 2016 11:55:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v3 2/2] mm/percpu.c: fix potential memory leakage for
 pcpu_embed_first_chunk()
Message-ID: <20161005155558.GE26977@htj.duckdns.org>
References: <db08c942-ff7b-d008-27de-57b9348f1904@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <db08c942-ff7b-d008-27de-57b9348f1904@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

On Wed, Oct 05, 2016 at 09:30:24PM +0800, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> in order to ensure the percpu group areas within a chunk aren't
> distributed too sparsely, pcpu_embed_first_chunk() goes to error handling
> path when a chunk spans over 3/4 VMALLOC area, however, during the error
> handling, it forget to free the memory allocated for all percpu groups by
> going to label @out_free other than @out_free_areas.

Applied 1-2 to percpu/for-4.9.

Thanks for the persistence!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
