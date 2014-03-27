Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 86BEE6B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 10:57:47 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id 63so2881263qgz.20
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 07:57:47 -0700 (PDT)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id y7si1132181qci.23.2014.03.27.07.57.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 07:57:46 -0700 (PDT)
Received: by mail-qc0-f179.google.com with SMTP id m20so4358844qcx.38
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 07:57:46 -0700 (PDT)
Date: Thu, 27 Mar 2014 10:57:43 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] mm/percpu.c: renew the max_contig if we merge the
 head and previous block.
Message-ID: <20140327145743.GC18503@htj.dyndns.org>
References: <1395918343-6775-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1395918343-6775-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, cl@linux-foundation.org, linux-kernel@vger.kernel.org

On Thu, Mar 27, 2014 at 07:05:43PM +0800, Jianyu Zhan wrote:
> During pcpu_alloc_area(), we might merge the current head with the
> previous block. Since we have calculated the max_contig using the
> size of previous block before we skip it, and now we update the size
> of previous block, so we should renew the max_contig.

pcpu_alloc_area() has been reimplemented in percpu/for-3.15.  Can you
please refresh the patch against the new implementation?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
