Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id D09546B005A
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 10:23:32 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id m20so260159qcx.8
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 07:23:32 -0800 (PST)
Received: from mail-qe0-x22d.google.com (mail-qe0-x22d.google.com [2607:f8b0:400d:c02::22d])
        by mx.google.com with ESMTPS id nh12si76701109qeb.4.2014.01.07.07.23.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 07:23:32 -0800 (PST)
Received: by mail-qe0-f45.google.com with SMTP id 6so470439qea.32
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 07:23:31 -0800 (PST)
Date: Tue, 7 Jan 2014 10:23:28 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] mm: free memblock.memory in free_all_bootmem
Message-ID: <20140107152328.GB3231@htj.dyndns.org>
References: <1389107774-54978-1-git-send-email-phacht@linux.vnet.ibm.com>
 <1389107774-54978-3-git-send-email-phacht@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389107774-54978-3-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, tangchen@cn.fujitsu.com, toshi.kani@hp.com

On Tue, Jan 07, 2014 at 04:16:14PM +0100, Philipp Hachtmann wrote:
> When calling free_all_bootmem() the free areas under memblock's
> control are released to the buddy allocator. Additionally the
> reserved list is freed if it was reallocated by memblock.
> The same should apply for the memory list.
> 
> Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
