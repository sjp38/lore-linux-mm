Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 690726B0037
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 09:30:51 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so1371082eek.4
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 06:30:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l2si4107663een.20.2014.01.09.06.30.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 06:30:50 -0800 (PST)
Date: Thu, 9 Jan 2014 15:30:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: Do not hang on OOM when killed by userspace OOM
 access to memory reserves
Message-ID: <20140109143048.GE27538@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
 <20131212103159.GB2630@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com>
 <20131217162342.GG28991@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com>
 <20131218200434.GA4161@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
 <20131219144134.GH10855@dhcp22.suse.cz>
 <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org>
 <20140108103319.GF27937@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140108103319.GF27937@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Wed 08-01-14 11:33:19, Michal Hocko wrote:
> On Tue 07-01-14 16:25:03, Andrew Morton wrote:
> [...]
> > > OK, so can we at least agree on the patch posted here:
> > > https://lkml.org/lkml/2013/12/12/129. This is a real bug and definitely
> > > worth fixing.
> > 
> > Yes, can we please get Eric's bug fixed?  I don't believe that Eric has
> > tested either https://lkml.org/lkml/2013/12/12/129 or
> > http://ozlabs.org/~akpm/mmots/broken-out/mm-memcg-avoid-oom-notification-when-current-needs-access-to-memory-reserves.patch.
> > Is he the only person who can reproduce this?
> 
> I have gathered 3 patches from all the discussion and plan to post them
> today or tomorrow as the time permits. https://lkml.org/lkml/2013/12/12/129
> will be a part of it.

OK, I've decided to post the oom notification parts later because they
will likely generate some discussion which might distract from the
actual fix so here it goes (can be applied on both mmotm and the current
Linus' tree):
---
