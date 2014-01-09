Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC2F6B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 17:48:53 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id um1so3606609pbc.34
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 14:48:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gx4si5082991pbc.201.2014.01.09.14.47.59
        for <linux-mm@kvack.org>;
        Thu, 09 Jan 2014 14:48:29 -0800 (PST)
Date: Thu, 9 Jan 2014 14:47:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current
 needs access to memory reserves
Message-Id: <20140109144757.e95616b4280c049b22743a15@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1401091324120.31538@chino.kir.corp.google.com>
References: <20131210103827.GB20242@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com>
	<20131211095549.GA18741@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
	<20131212103159.GB2630@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com>
	<20131217162342.GG28991@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com>
	<20131218200434.GA4161@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
	<20131219144134.GH10855@dhcp22.suse.cz>
	<20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org>
	<alpine.DEB.2.02.1401091324120.31538@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Thu, 9 Jan 2014 13:34:24 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Tue, 7 Jan 2014, Andrew Morton wrote:
> 
> > I just spent a happy half hour reliving this thread and ended up
> > deciding I agreed with everyone!  I appears that many more emails are
> > needed so I think I'll drop
> > http://ozlabs.org/~akpm/mmots/broken-out/mm-memcg-avoid-oom-notification-when-current-needs-access-to-memory-reserves.patch
> > for now.
> > 
> > The claim that
> > mm-memcg-avoid-oom-notification-when-current-needs-access-to-memory-reserves.patch
> > will impact existing userspace seems a bit dubious to me.
> > 
> 
> I'm not sure why this was dropped since it's vitally needed for any sane 
> userspace oom handler to be effective.

It was dropped because the other memcg developers disagreed with it.

I'd really prefer not to have to spend a great amount of time parsing
argumentative and repetitive emails to make a tie-break decision which
may well be wrong anyway.

Please work with the other guys to find an acceptable implementation. 
There must be *something* we can do?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
