Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2946B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 08:22:12 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ne4so36412675lbc.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:22:12 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id g6si7327734wjy.129.2016.06.03.05.22.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 05:22:11 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n184so22669502wmn.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:22:10 -0700 (PDT)
Date: Fri, 3 Jun 2016 14:22:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
Message-ID: <20160603122209.GH20676@dhcp22.suse.cz>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
 <201606032100.AIH12958.HMOOOFLJSFQtVF@I-love.SAKURA.ne.jp>
 <20160603122030.GG20676@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160603122030.GG20676@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 03-06-16 14:20:30, Michal Hocko wrote:
[...]
> Do no take me wrong but I would rather make sure that the current pile
> is reviewed and no unintentional side effects are introduced than open
> yet another can of worms.

And just to add. You have found many buugs in the previous versions of
the patch series so I would really appreciate your Acked-by or
Reviewed-by if you feel confortable with those changes or express your
concerns.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
