Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6545E6B0039
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 10:29:19 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so5774578wgh.24
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 07:29:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ey9si8761357wib.36.2014.06.16.07.29.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 07:29:17 -0700 (PDT)
Date: Mon, 16 Jun 2014 16:29:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: Allow guarantee reclaim
Message-ID: <20140616142915.GF16915@dhcp22.suse.cz>
References: <1402473624-13827-2-git-send-email-mhocko@suse.cz>
 <20140611153631.GH2878@cmpxchg.org>
 <20140612132207.GA32720@dhcp22.suse.cz>
 <20140612135600.GI2878@cmpxchg.org>
 <20140612142237.GB32720@dhcp22.suse.cz>
 <20140612161733.GC23606@htj.dyndns.org>
 <20140616125915.GB16915@dhcp22.suse.cz>
 <20140616135741.GA11542@htj.dyndns.org>
 <20140616140448.GE16915@dhcp22.suse.cz>
 <20140616141233.GB11542@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140616141233.GB11542@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On Mon 16-06-14 10:12:33, Tejun Heo wrote:
> On Mon, Jun 16, 2014 at 04:04:48PM +0200, Michal Hocko wrote:
> > > For whatever reason, a user is stuck with thread-level granularity for
> > > controllers which work that way, the user can use the old hierarchies
> > > for them for the time being.
> > 
> > So he can mount memcg with new cgroup API and others with old?
> 
> Yes, you can read Documentation/cgroups/unified-hierarchy.txt for more
> details.  I think I cc'd you when posting unified hierarchy patchset,
> didn't I?

OK, I've obviously pushed that out of my brain, because you are really
clear about it:
"
All controllers which are not bound to other hierarchies are
automatically bound to unified hierarchy and show up at the root of
it. Controllers which are enabled only in the root of unified
hierarchy can be bound to other hierarchies at any time.  This allows
mixing unified hierarchy with the traditional multiple hierarchies in
a fully backward compatible way.
"

This of course sorts out my concerns. Sorry about the noise!

> > > Nope, some changes don't fit that model.  CFTYPE_ON_ON_DFL is the
> > > opposite. 
> > 
> > OK, I wasn't aware of this. On which branch I find this?
> 
> They're all in the mainline now.

git grep CFTYPE_ON_ON_DFL origin/master didn't show me anything.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
