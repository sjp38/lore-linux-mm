Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 105B76B0037
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 12:36:18 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id y10so7412252wgg.29
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:36:18 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id fw4si10844697wib.96.2014.06.17.09.36.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 09:36:17 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so6188722wiv.10
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:36:17 -0700 (PDT)
Date: Tue, 17 Jun 2014 18:36:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 00/12] mm: memcontrol: naturalize charge lifetime v3
Message-ID: <20140617163615.GD9572@dhcp22.suse.cz>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-06-14 15:54:20, Johannes Weiner wrote:
> Hi,
> 
> this is v3 of the memcg charge naturalization series.  Changes since
> v2 include:
> 
> o make THP charges use __GFP_NORETRY to prevent excessive reclaim (Michal)
> o simplify move precharging while in the area
> o add acks & rebase to v3.16-rc1

I still didn't get to the last two patches and they need a more
throughout review. The rest is good and nice on its own and maybe it
would be easier if those go in first.

I would like to get to the last two ASAP but this is heavier and I am
quite swamped by other small tasks last weeks so I do not want to delay
the whole series.

What do you think?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
