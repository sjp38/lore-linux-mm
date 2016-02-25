Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5E83E6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 04:48:47 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id q63so30137448pfb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:48:47 -0800 (PST)
Received: from us-alimail-mta2.hst.scl.en.alidc.net (mail113-248.mail.alibaba.com. [205.204.113.248])
        by mx.google.com with ESMTP id e29si11457191pfb.131.2016.02.25.01.48.44
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 01:48:46 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <20160203132718.GI6757@dhcp22.suse.cz> <alpine.LSU.2.11.1602241832160.15564@eggly.anvils> <20160225064845.GA505@swordfish> <000001d16fad$63fff840$2bffe8c0$@alibaba-inc.com> <20160225092739.GE17573@dhcp22.suse.cz>
In-Reply-To: <20160225092739.GE17573@dhcp22.suse.cz>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Date: Thu, 25 Feb 2016 17:48:26 +0800
Message-ID: <000201d16fb1$acc98ec0$065cac40$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: 'Sergey Senozhatsky' <sergey.senozhatsky.work@gmail.com>, 'Hugh Dickins' <hughd@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@i-love.sakura.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>

> >
> > Can you please schedule a run for the diff attached, in which
> > non-expensive allocators are allowed to burn more CPU cycles.
> 
> I do not think your patch will help. As you can see, both OOMs were for
> order-2 and there simply are no order-2+ free blocks usable for the
> allocation request so the watermark check will fail for all eligible
> zones and no_progress_loops is simply ignored. This is what I've tried
> to address by patch I have just posted as a reply to Hugh's email
> http://lkml.kernel.org/r/20160225092315.GD17573@dhcp22.suse.cz
> 
Hm, Mr. Swap can tell us more.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
