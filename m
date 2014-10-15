Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1976A6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 05:40:35 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id z12so701537lbi.2
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 02:40:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bf9si9033663lab.114.2014.10.15.02.40.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Oct 2014 02:40:33 -0700 (PDT)
Date: Wed, 15 Oct 2014 11:40:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20141015094031.GC23547@dhcp22.suse.cz>
References: <1413251163-8517-1-git-send-email-hannes@cmpxchg.org>
 <1413251163-8517-2-git-send-email-hannes@cmpxchg.org>
 <20141014155647.GA6414@dhcp22.suse.cz>
 <20141014163354.GA23911@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141014163354.GA23911@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 14-10-14 12:33:54, Johannes Weiner wrote:
> On Tue, Oct 14, 2014 at 05:56:47PM +0200, Michal Hocko wrote:
[...]
> > You have only missed MAINTAINERS...
> 
> Hm, we can add it, but then again scripts/get_maintainer.pl should
> already do the right thing.

OK, that would work as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
