Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEDC6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 22:56:02 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so769399pad.24
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 19:56:02 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id qv5si2859676pbb.227.2014.08.13.19.55.59
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 19:56:01 -0700 (PDT)
Date: Wed, 13 Aug 2014 19:55:58 -0700 (PDT)
Message-Id: <20140813.195558.2039710996129294402.davem@davemloft.net>
Subject: Re: [PATCH v14 3/8] sparc: add pmd_[dirty|mkclean] for THP
From: David Miller <davem@davemloft.net>
In-Reply-To: <1407981212-17818-4-git-send-email-minchan@kernel.org>
References: <1407981212-17818-1-git-send-email-minchan@kernel.org>
	<1407981212-17818-4-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtk.manpages@gmail.com, linux-api@vger.kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, mgorman@suse.de, je@fb.com, zhangyanfei@cn.fujitsu.com, kirill@shutemov.name, sparclinux@vger.kernel.org

From: Minchan Kim <minchan@kernel.org>
Date: Thu, 14 Aug 2014 10:53:27 +0900

> MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
> overwrite of the contents since MADV_FREE syscall is called for
> THP page.
> 
> This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
> support.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: sparclinux@vger.kernel.org
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
