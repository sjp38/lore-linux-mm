Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id DEB29828E4
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 02:37:23 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id r97so65689034lfi.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 23:37:23 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id r142si8396491lfe.374.2016.07.21.23.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 23:37:22 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id x83so4738013wma.3
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 23:37:21 -0700 (PDT)
Date: Fri, 22 Jul 2016 08:37:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from the
 reclaim path
Message-ID: <20160722063720.GB794@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <20160719135426.GA31229@cmpxchg.org>
 <alpine.DEB.2.10.1607191315400.58064@chino.kir.corp.google.com>
 <20160720081541.GF11249@dhcp22.suse.cz>
 <alpine.DEB.2.10.1607201353230.22427@chino.kir.corp.google.com>
 <20160721085202.GC26379@dhcp22.suse.cz>
 <20160721121300.GA21806@cmpxchg.org>
 <20160721145309.GR26379@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160721145309.GR26379@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On Thu 21-07-16 16:53:09, Michal Hocko wrote:
> From d64815758c212643cc1750774e2751721685059a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 21 Jul 2016 16:40:59 +0200
> Subject: [PATCH] Revert "mm, mempool: only set __GFP_NOMEMALLOC if there are
>  free elements"
> 
> This reverts commit f9054c70d28bc214b2857cf8db8269f4f45a5e23.

I've noticed that Andrew has already picked this one up. Is anybody
against marking it for stable?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
