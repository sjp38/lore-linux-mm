Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC5B96B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 14:54:18 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id s4-v6so11815361ybg.2
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 11:54:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z132-v6sor6466568ybz.3.2018.04.26.11.54.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 11:54:17 -0700 (PDT)
Date: Thu, 26 Apr 2018 11:54:14 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] memcg: writeback: use memcg->cgwb_list directly
Message-ID: <20180426185414.GN1911913@devbig577.frc2.facebook.com>
References: <1524406173-212182-1-git-send-email-wanglong19@meituan.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1524406173-212182-1-git-send-email-wanglong19@meituan.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <wanglong19@meituan.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org, khlebnikov@yandex-team.ru, xboe@kernel.dk, jack@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com

On Sun, Apr 22, 2018 at 10:09:33PM +0800, Wang Long wrote:
> mem_cgroup_cgwb_list is a very simple wrapper and it will
> never be used outside of code under CONFIG_CGROUP_WRITEBACK.
> so use memcg->cgwb_list directly.
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Wang Long <wanglong19@meituan.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
