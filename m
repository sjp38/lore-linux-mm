Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 079016B0253
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 09:28:46 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id y9so35794856ywy.2
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 06:28:46 -0700 (PDT)
Received: from mail-qt0-f182.google.com (mail-qt0-f182.google.com. [209.85.216.182])
        by mx.google.com with ESMTPS id b47si1351341uaa.154.2016.10.20.06.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 06:28:45 -0700 (PDT)
Received: by mail-qt0-f182.google.com with SMTP id f6so55602944qtd.2
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 06:28:45 -0700 (PDT)
Date: Thu, 20 Oct 2016 15:28:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] bdi flusher should not be throttled here when it fall
 into buddy slow path
Message-ID: <20161020132842.GM14609@dhcp22.suse.cz>
References: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
 <1476967085-89647-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476967085-89647-1-git-send-email-zhouxianrong@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, mingo@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, vdavydov.dev@gmail.com, minchan@kernel.org, riel@redhat.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

On Thu 20-10-16 20:38:05, zhouxianrong@huawei.com wrote:
> From: z00281421 <z00281421@notesmail.huawei.com>
> 
> The bdi flusher should be throttled only depends on 
> own bdi and is decoupled with others.
> 
> separate PGDAT_WRITEBACK into PGDAT_ANON_WRITEBACK and
> PGDAT_FILE_WRITEBACK avoid scanning anon lru and it is ok 
> then throttled on file WRITEBACK.

Could you please answer questions from
http://lkml.kernel.org/r/20161018114207.GD12092@dhcp22.suse.cz before
coming up with new and even more complex patches please?

I would really like to understand the issue you are seeing before
jumping into patches...

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
