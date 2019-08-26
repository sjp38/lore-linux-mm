Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CD76C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 23:14:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3598220850
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 23:14:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VHZMbHg3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3598220850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A70506B0289; Mon, 26 Aug 2019 19:14:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1EDD6B028A; Mon, 26 Aug 2019 19:14:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 935C36B028B; Mon, 26 Aug 2019 19:14:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0240.hostedemail.com [216.40.44.240])
	by kanga.kvack.org (Postfix) with ESMTP id 7179E6B0289
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:14:36 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1E5342C6D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 23:14:36 +0000 (UTC)
X-FDA: 75866135352.16.ink75_281eaa7045a18
X-HE-Tag: ink75_281eaa7045a18
X-Filterd-Recvd-Size: 3387
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 23:14:35 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 82E7320850;
	Mon, 26 Aug 2019 23:14:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566861274;
	bh=ypwsaTVS6nsi6PTJ3bURcKwvmMX8OQa7n0jU+BYXp4M=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=VHZMbHg3W64NmF5WiEc17MDF71dDIJhYgbMa07+Sv+ze5Fvheuk7+VX2mH7/nPcCK
	 PTZRa/in8lnlrDGF+2JNGA0pOEBiItyuQyqLoo2u8yBzrYFWyCJl/FNE3s70vFljqL
	 C4JH30cHLN5McjP6TCCOfR68LYgB9Csxv2w9LXTU=
Date: Mon, 26 Aug 2019 16:14:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Sergey
 Senozhatsky <sergey.senozhatsky@gmail.com>, Linux Memory Management List
 <linux-mm@kvack.org>, Henry Burns <henrywolfeburns@gmail.com>
Subject: Re: [mmotm:master 14/264] mm/zsmalloc.c:2415:27: error: 'struct
 zs_pool' has no member named 'migration_wait'
Message-Id: <20190826161434.1ed94d3e4c93833f54dddb01@linux-foundation.org>
In-Reply-To: <201908251039.5oSbEEUT%lkp@intel.com>
References: <201908251039.5oSbEEUT%lkp@intel.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 25 Aug 2019 10:53:43 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   f50a6baf25034cdc74a3c2a919c455076f776944
> commit: 5e656681183d9045de7815921012f5731c16eae3 [14/264] mm/zsmalloc.c: fix race condition in zs_destroy_pool
> config: i386-randconfig-c003-201934 (attached as .config)
> compiler: gcc-7 (Debian 7.4.0-10) 7.4.0
> reproduce:
>         git checkout 5e656681183d9045de7815921012f5731c16eae3
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from include/linux/mmzone.h:10:0,
>                     from include/linux/gfp.h:6,
>                     from include/linux/umh.h:4,
>                     from include/linux/kmod.h:9,
>                     from include/linux/module.h:13,
>                     from mm/zsmalloc.c:33:
>    mm/zsmalloc.c: In function 'zs_create_pool':
> >> mm/zsmalloc.c:2415:27: error: 'struct zs_pool' has no member named 'migration_wait'
>      init_waitqueue_head(&pool->migration_wait);
>                               ^
>    include/linux/wait.h:67:26: note: in definition of macro 'init_waitqueue_head'
>       __init_waitqueue_head((wq_head), #wq_head, &__key);  \

Thanks.

--- a/mm/zsmalloc.c~mm-zsmallocc-fix-build-when-config_compaction=n
+++ a/mm/zsmalloc.c
@@ -2412,7 +2412,9 @@ struct zs_pool *zs_create_pool(const cha
 	if (!pool->name)
 		goto err;
 
+#ifdef CONFIG_COMPACTION
 	init_waitqueue_head(&pool->migration_wait);
+#endif
 
 	if (create_cache(pool))
 		goto err;
_


