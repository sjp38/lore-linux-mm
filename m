Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 38AA26B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 12:01:29 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id wz12so10802748pbc.41
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 09:01:28 -0800 (PST)
Date: Mon, 7 Jan 2013 09:01:24 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] mm: memblock: fix wrong memmove size in
 memblock_merge_regions()
Message-ID: <20130107170124.GK3926@htj.dyndns.org>
References: <1357530096-28548-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357530096-28548-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, yinghai@kernel.org, liwanp@linux.vnet.ibm.com, benh@kernel.crashing.org, tangchen@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 07, 2013 at 11:41:36AM +0800, Lin Feng wrote:
> The memmove span covers from (next+1) to the end of the array, and the index
> of next is (i+1), so the index of (next+1) is (i+2). So the size of remaining
> array elements is (type->cnt - (i + 2)).
> 
> Cc: Tejun Heo <tj@kernel.org>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
