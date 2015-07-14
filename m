Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id E7EB4280268
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:58:57 -0400 (EDT)
Received: by ietj16 with SMTP id j16so21154604iet.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:58:57 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id dp6si2479818icb.67.2015.07.14.14.58.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 14:58:57 -0700 (PDT)
Received: by igbij6 with SMTP id ij6so57276858igb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:58:57 -0700 (PDT)
Date: Tue, 14 Jul 2015 14:58:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] oom: Do not invoke oom notifiers on sysrq+f
In-Reply-To: <20150710074032.GA7343@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1507141458350.16182@chino.kir.corp.google.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com> <1436360661-31928-3-git-send-email-mhocko@suse.com> <alpine.DEB.2.10.1507081636180.16585@chino.kir.corp.google.com> <20150709085505.GB13872@dhcp22.suse.cz> <alpine.DEB.2.10.1507091404200.17177@chino.kir.corp.google.com>
 <20150710074032.GA7343@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 10 Jul 2015, Michal Hocko wrote:

> Shrinkers are there to reclaim and prevent from OOM. This API is a gray
> zone. It looks generic method for the notification yet it allows to
> prevent from oom killer. I can imagine somebody might abuse this
> interface to implement OOM killer policies.
> 
> Anyway, I think it would be preferable to kill it altogether rather than
> play with its placing. It will always be a questionable API.
> 

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
