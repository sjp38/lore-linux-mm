Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3660D6B006C
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 07:56:45 -0500 (EST)
Received: by wghl18 with SMTP id l18so5939061wgh.5
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 04:56:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e18si12440620wjx.62.2015.03.05.04.56.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 04:56:43 -0800 (PST)
Date: Thu, 5 Mar 2015 13:56:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: make CONFIG_MEMCG depend on CONFIG_MMU
Message-ID: <20150305125641.GB19347@dhcp22.suse.cz>
References: <1425492428-27562-1-git-send-email-mhocko@suse.cz>
 <20150304190635.GC21350@phnom.home.cmpxchg.org>
 <20150304192836.GA952@dhcp22.suse.cz>
 <20150304211301.GA22626@phnom.home.cmpxchg.org>
 <20150304132126.90dad77e36b21016b5a411a4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150304132126.90dad77e36b21016b5a411a4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chen Gang <762976180@qq.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>

On Wed 04-03-15 13:21:26, Andrew Morton wrote:
> On Wed, 4 Mar 2015 16:13:01 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > I don't even care about NOMMU, this is just wrong on principle.
> 
> Agree.  And I do care about nommu ;)
> 
> If some nommu person wants to start using memcg and manages to get it
> doing something useful then good for them - we end up with a better
> kernel.  We shouldn't go and rule this out without having even tried it.

Fair enough, but shouldn't we be explicit (and honest) that the
configuration is currently broken and hardly usable?

Would it make sense to make MEMCG depend on BROKEN for !MMU? If somebody
really has an usecase then dependency on BROKEN would suggest there is a
work to be done before it is enabled for his/her configuration. I would
expect such a user would send us an email when noticing this and submit
a bug report so that we can help making it work.
---
