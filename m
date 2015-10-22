Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id DEAB56B0255
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 10:25:51 -0400 (EDT)
Received: by qkcy65 with SMTP id y65so54151365qkc.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:25:51 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id w18si12351354qgw.18.2015.10.22.07.25.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 22 Oct 2015 07:25:51 -0700 (PDT)
Date: Thu, 22 Oct 2015 09:25:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
In-Reply-To: <20151022142429.GC30579@mtj.duckdns.org>
Message-ID: <alpine.DEB.2.20.1510220925160.23638@east.gentwo.org>
References: <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org> <20151021143337.GD8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org> <20151021145505.GE8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org> <20151022140944.GA30579@mtj.duckdns.org> <20151022142155.GB30579@mtj.duckdns.org> <alpine.DEB.2.20.1510220923130.23591@east.gentwo.org>
 <20151022142429.GC30579@mtj.duckdns.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu, 22 Oct 2015, Tejun Heo wrote:

> On Thu, Oct 22, 2015 at 09:23:54AM -0500, Christoph Lameter wrote:
> > I guess we need that otherwise vm statistics are not updated while worker
> > threads are blocking on memory reclaim.
>
> And the blocking one is just constantly running?

I was told that there is just one task struct so additional work queue
items cannot be processed while waiting?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
