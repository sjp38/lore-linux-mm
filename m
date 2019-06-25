Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C54CAC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:00:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B6DC208CA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:00:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hxkgJe/p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B6DC208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9A846B0003; Tue, 25 Jun 2019 18:00:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4C758E0003; Tue, 25 Jun 2019 18:00:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3ADA8E0002; Tue, 25 Jun 2019 18:00:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB836B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 18:00:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f25so157195pfk.14
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:00:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=22DJjEQWkC8EWatRUBs1yebnxoLMG2c+StSo6htLAO4=;
        b=S441XoTzmTVDyJmRdm3YjKEW2/eDLaScGI2f7TDnAWrh3It22ox41ADKQsJ8btvRBN
         IGkuv772ALoIoA0YIA1rb1fEI7RaUX8qwFU6jOFRDeqrz591fpInEmM8QhOwiO4mKk3t
         w2BpkqPxaYfSYbQPDbUisYtaNsw4zmjaZA9T1w1XLecEltY0EyFf+DOk4tiX0TWSO3EZ
         3AWJs2pEw9q/BbUo1FbnEUwNcF4bxUZu+Cc8POJtV3HEUalh0ARJ+PwxPGzeYuLp8HJQ
         spGe+HchYEcqINTBRLwQKnOo73B9gHdaRrIXDhLn18Lt6BG6YBWHdKx1j9vllT+OPotV
         hytQ==
X-Gm-Message-State: APjAAAXwjJMz2IDi7cyoYWycxuBykuaOD9/mit/HN+KvLI36RjjsyPSv
	e0qXhTpGodfCE5AHl+K6P7w6J8ktHp1L9QQYIgmiWGCENgZBP4VGgzYOAt/nGU568Ivp+/cyeZ7
	2s9hMwwju+LZQVxm4ydN3U5BsHP4NzlgR+YBE8eT1B+FEeZXMSwlHCSVsZv9QEqXmJw==
X-Received: by 2002:a63:1b5c:: with SMTP id b28mr31958919pgm.101.1561500042833;
        Tue, 25 Jun 2019 15:00:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBzL1pfNFzYZY/QcpxqFMqpBxK9hxDrsVTgs0N9FarRq1mXrOckvmuSmdd4OxVmyVGCdNK
X-Received: by 2002:a63:1b5c:: with SMTP id b28mr31958836pgm.101.1561500041894;
        Tue, 25 Jun 2019 15:00:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561500041; cv=none;
        d=google.com; s=arc-20160816;
        b=U5wotFZG6a2x6NJvtQToIhdEnUWXekhiId2wON+/ZSRGTueWues4yNqZNQwEZzjoc+
         5PfVMasMiQ3cQc9ugs99FNpusKS9yLRNHjqNp+QjQIj/9CfPKETVXOFo+I8OAtB7TThI
         3346zz6BrMPGToQi5U/khj1zJG3Z25Jwh+9ct8UCFwWEbl1CKtvQ2yczGNd+EEiujqlp
         EI6w281aY171DzJ0eiQDs+4IdWut2mfNDAmA9Uqre8gXAcTot2cwT2ixf4k+1JusYsfL
         dnYz52jQQsTMZ6NuY2LU4a5WAps92nNTxx9Z7/xeq4sLqm5d3LLem2aM4hiND+ZxzX3T
         5LNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=22DJjEQWkC8EWatRUBs1yebnxoLMG2c+StSo6htLAO4=;
        b=X7pCOeMIP40jHPWxXcpowNgy/wR7Cy8xyl4FAv6U89DHlZYrAuidSenz2GoF4a554I
         8/ynqFgWQ89UU37fzAzTU6Aji74d/bmDrB70xa9ynVlVvwpbgebBxYO+eNw71QMvNeRg
         RSOLP9oJivWH/6edQ2+VpbjYTTJzwo9jQsB5/ekpsoh4a7akd2Pqa9Ar5QHMsBQ7OtJ8
         buIG22ufFdZJl7L1GVFMm8xYTAc37UreyYlHn7kecsY/vdhuBM7gjQ5yoHjQAXtLGJ7Q
         JxiM8wbV3fC9ycKAMODWfUpyQbrVYgLHSB2l8tYxpqbz+q6bVUBo3xA4g7FvNLTUk/XO
         H/hA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="hxkgJe/p";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 7si12437838pga.320.2019.06.25.15.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 15:00:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="hxkgJe/p";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 14F962080C;
	Tue, 25 Jun 2019 22:00:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561500041;
	bh=F3zOuj+AQCm4B3i9sQrKyEWYHwxAH26odI9Vxhs+EvI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=hxkgJe/pFbcy2wWEYYVcugv6LTv99BMAZVGwtVsElaZXu3NeeoVr7u5ZvvMtKXuhl
	 VfsD5X/2GkepCxINxodk4b0M6ZVxwm3RoAZAoPobGTwN4rcTC2prnyg4ExCfL3ujQb
	 n3OvN+ZqeLnPYNafzBYElyBLgUP29Ys135xarID0=
Date: Tue, 25 Jun 2019 15:00:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH 4/4] mm: thp: make deferred split shrinker memcg
 aware
Message-Id: <20190625150040.feb6ea9d11fff73a57320a3c@linux-foundation.org>
In-Reply-To: <1560376609-113689-5-git-send-email-yang.shi@linux.alibaba.com>
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
	<1560376609-113689-5-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jun 2019 05:56:49 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> Currently THP deferred split shrinker is not memcg aware, this may cause
> premature OOM with some configuration. For example the below test would
> run into premature OOM easily:
> 
> $ cgcreate -g memory:thp
> $ echo 4G > /sys/fs/cgroup/memory/thp/memory/limit_in_bytes
> $ cgexec -g memory:thp transhuge-stress 4000
> 
> transhuge-stress comes from kernel selftest.
> 
> It is easy to hit OOM, but there are still a lot THP on the deferred
> split queue, memcg direct reclaim can't touch them since the deferred
> split shrinker is not memcg aware.
> 
> Convert deferred split shrinker memcg aware by introducing per memcg
> deferred split queue.  The THP should be on either per node or per memcg
> deferred split queue if it belongs to a memcg.  When the page is
> immigrated to the other memcg, it will be immigrated to the target
> memcg's deferred split queue too.
> 
> Reuse the second tail page's deferred_list for per memcg list since the
> same THP can't be on multiple deferred split queues.
> 
> ...
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4579,6 +4579,11 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  #ifdef CONFIG_CGROUP_WRITEBACK
>  	INIT_LIST_HEAD(&memcg->cgwb_list);
>  #endif
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	spin_lock_init(&memcg->deferred_split_queue.split_queue_lock);
> +	INIT_LIST_HEAD(&memcg->deferred_split_queue.split_queue);
> +	memcg->deferred_split_queue.split_queue_len = 0;
> +#endif
>  	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
>  	return memcg;
>  fail:
> @@ -4949,6 +4954,14 @@ static int mem_cgroup_move_account(struct page *page,
>  		__mod_memcg_state(to, NR_WRITEBACK, nr_pages);
>  	}
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	if (compound && !list_empty(page_deferred_list(page))) {
> +		spin_lock(&from->deferred_split_queue.split_queue_lock);
> +		list_del(page_deferred_list(page));

It's worrisome that this page still appears to be on the deferred_list
and that the above if() would still succeed.  Should this be
list_del_init()?

> +		from->deferred_split_queue.split_queue_len--;
> +		spin_unlock(&from->deferred_split_queue.split_queue_lock);
> +	}
> +#endif

