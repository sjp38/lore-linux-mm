Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0CB6B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 11:50:21 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so3788997eek.12
        for <linux-mm@kvack.org>; Mon, 19 May 2014 08:50:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 42si1399949eea.252.2014.05.19.08.50.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 08:50:20 -0700 (PDT)
Date: Mon, 19 May 2014 17:50:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: deprecate memory.force_empty knob
Message-ID: <20140519155018.GF3017@dhcp22.suse.cz>
References: <1399994956-3907-1-git-send-email-mhocko@suse.cz>
 <xr9338g9o03z.fsf@gthelen.mtv.corp.google.com>
 <20140519140248.GD3017@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140519140248.GD3017@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 19-05-14 16:02:48, Michal Hocko wrote:
> On Fri 16-05-14 15:00:16, Greg Thelen wrote:
[...]
> > -- First, demonstrate that just rmdir, without memory.force_empty,
> >    temporarily hides reparented child memory stats.
> > 
> > $ /test
> > p/memory.stat:rss 0
> > p/memory.stat:total_rss 69632
> > p/c/memory.stat:rss 69632
> > p/c/memory.stat:total_rss 69632
> > For a small time the p/c memory has not been reparented to p.
> > p/memory.stat:rss 0
> > p/memory.stat:total_rss 0
> 
> OK, this is a bug. Our iterators skip the children because css_tryget
> fails on it but css_offline still not done.

Or use the cgroups iterator directly. Which would be even easier to fix.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
