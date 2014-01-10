Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id A09FF6B0035
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 03:30:27 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so1909949eaj.7
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 00:30:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si8585612eeg.30.2014.01.10.00.30.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 00:30:26 -0800 (PST)
Date: Fri, 10 Jan 2014 09:30:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20140110083025.GE9437@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com>
 <20131217162342.GG28991@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com>
 <20131218200434.GA4161@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
 <20131219144134.GH10855@dhcp22.suse.cz>
 <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org>
 <alpine.DEB.2.02.1401091324120.31538@chino.kir.corp.google.com>
 <20140109144757.e95616b4280c049b22743a15@linux-foundation.org>
 <alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Thu 09-01-14 16:01:15, David Rientjes wrote:
> On Thu, 9 Jan 2014, Andrew Morton wrote:
> 
> > > I'm not sure why this was dropped since it's vitally needed for any sane 
> > > userspace oom handler to be effective.
> > 
> > It was dropped because the other memcg developers disagreed with it.
> > 
> 
> It was acked-by Michal.

I have already explained why I have acked it. I will not repeat
it here again. I have also proposed an alternative solution
(https://lkml.org/lkml/2013/12/12/174) which IMO is more viable because
it handles both user/kernel memcg OOM consistently. This patch still has
to be discussed because of other Johannes concerns. I plan to repost it
in a near future.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
