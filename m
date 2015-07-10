Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 531EA6B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 03:40:38 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so58781576wgx.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 00:40:38 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id cb14si2138527wib.23.2015.07.10.00.40.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 00:40:36 -0700 (PDT)
Received: by wifm2 with SMTP id m2so38587205wif.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 00:40:35 -0700 (PDT)
Date: Fri, 10 Jul 2015 09:40:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] oom: Do not invoke oom notifiers on sysrq+f
Message-ID: <20150710074032.GA7343@dhcp22.suse.cz>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com>
 <1436360661-31928-3-git-send-email-mhocko@suse.com>
 <alpine.DEB.2.10.1507081636180.16585@chino.kir.corp.google.com>
 <20150709085505.GB13872@dhcp22.suse.cz>
 <alpine.DEB.2.10.1507091404200.17177@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507091404200.17177@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 09-07-15 14:07:37, David Rientjes wrote:
> On Thu, 9 Jul 2015, Michal Hocko wrote:
[...]
> > So I am not
> > sure it belongs outside of the oom killer proper.
> > 
> 
> Umm it has nothing to do with oom killing, it quite obviously doesn't 
> belong in the oom killer.

The naming of the API would disagree. To me register_oom_notifier sounds
like a mechanism to be notified when we are oom.

> It belongs prior to invoking the oom killer if memory could be freed.

Shrinkers are there to reclaim and prevent from OOM. This API is a gray
zone. It looks generic method for the notification yet it allows to
prevent from oom killer. I can imagine somebody might abuse this
interface to implement OOM killer policies.

Anyway, I think it would be preferable to kill it altogether rather than
play with its placing. It will always be a questionable API.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
