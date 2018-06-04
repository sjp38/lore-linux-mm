Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E6CC46B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 07:20:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 76-v6so2955334wmw.3
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 04:20:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h8-v6si3321955eda.272.2018.06.04.04.20.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jun 2018 04:20:28 -0700 (PDT)
Date: Mon, 4 Jun 2018 13:20:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add conditions to avoid out-of-bounds
Message-ID: <20180604112026.GI19202@dhcp22.suse.cz>
References: <20180604103735.42781-1-nixiaoming@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180604103735.42781-1-nixiaoming@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nixiaoming <nixiaoming@huawei.com>
Cc: akpm@linux-foundation.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org, garsilva@embeddedor.com, ktkhai@virtuozzo.com, stummala@codeaurora.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 04-06-18 18:37:35, nixiaoming wrote:
> In the function memcg_init_list_lru
> if call goto fail when i == 0, will cause out-of-bounds at lru->node[i]

How? All I can see is that the fail path does
	for (i = i - 1; i >= 0; i--)

so it will not do anything for i=0.
-- 
Michal Hocko
SUSE Labs
