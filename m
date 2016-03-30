Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id E2DAA6B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:10:48 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id p65so66354439wmp.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:10:48 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id w4si4398279wje.208.2016.03.30.04.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 04:10:46 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i204so11927732wmd.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:10:45 -0700 (PDT)
Date: Wed, 30 Mar 2016 13:10:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Revert "mm/page_alloc: protect pcp->batch accesses with
 ACCESS_ONCE"
Message-ID: <20160330111044.GA4324@dhcp22.suse.cz>
References: <1459333327-89720-1-git-send-email-hekuang@huawei.com>
 <20160330103839.GA4773@techsingularity.net>
 <56FBAFA0.3010604@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <56FBAFA0.3010604@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hekuang <hekuang@huawei.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, cody@linux.vnet.ibm.com, gilad@benyossef.com, kosaki.motohiro@gmail.com, mgorman@suse.de, penberg@kernel.org, lizefan@huawei.com, wangnan0@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 30-03-16 18:51:12, Hekuang wrote:
> hi
> 
> a?? 2016/3/30 18:38, Mel Gorman a??e??:
> >On Wed, Mar 30, 2016 at 10:22:07AM +0000, He Kuang wrote:
> >>This reverts commit 998d39cb236fe464af86a3492a24d2f67ee1efc2.
> >>
> >>When local irq is disabled, a percpu variable does not change, so we can
> >>remove the access macros and let the compiler optimize the code safely.
> >>
> >batch can be changed from other contexts. Why is this safe?
> >
> I've mistakenly thought that per_cpu variable can only be accessed by that
> cpu.

git blame would point you to 998d39cb236f ("mm/page_alloc: protect
pcp->batch accesses with ACCESS_ONCE"). I haven't looked into the code
deeply to confirm this is still the case but it would be a good lead
that this is not that simple. ACCESS_ONCE resp. {READ,WRITE}_ONCE are
usually quite subtle so I would encourage you or anybody else who try to
remove them to study the code and the history deeper before removing
them.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
