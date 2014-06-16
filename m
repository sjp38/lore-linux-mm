Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 57E546B0039
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 10:12:37 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id w7so6640388qcr.21
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 07:12:37 -0700 (PDT)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id z20si13370746qax.2.2014.06.16.07.12.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 07:12:36 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id j15so7489501qaq.12
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 07:12:36 -0700 (PDT)
Date: Mon, 16 Jun 2014 10:12:33 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: Allow guarantee reclaim
Message-ID: <20140616141233.GB11542@htj.dyndns.org>
References: <1402473624-13827-1-git-send-email-mhocko@suse.cz>
 <1402473624-13827-2-git-send-email-mhocko@suse.cz>
 <20140611153631.GH2878@cmpxchg.org>
 <20140612132207.GA32720@dhcp22.suse.cz>
 <20140612135600.GI2878@cmpxchg.org>
 <20140612142237.GB32720@dhcp22.suse.cz>
 <20140612161733.GC23606@htj.dyndns.org>
 <20140616125915.GB16915@dhcp22.suse.cz>
 <20140616135741.GA11542@htj.dyndns.org>
 <20140616140448.GE16915@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140616140448.GE16915@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On Mon, Jun 16, 2014 at 04:04:48PM +0200, Michal Hocko wrote:
> > For whatever reason, a user is stuck with thread-level granularity for
> > controllers which work that way, the user can use the old hierarchies
> > for them for the time being.
> 
> So he can mount memcg with new cgroup API and others with old?

Yes, you can read Documentation/cgroups/unified-hierarchy.txt for more
details.  I think I cc'd you when posting unified hierarchy patchset,
didn't I?

> > Nope, some changes don't fit that model.  CFTYPE_ON_ON_DFL is the
> > opposite. 
> 
> OK, I wasn't aware of this. On which branch I find this?

They're all in the mainline now.

> > Knobs marked with the flag only appear on the default
> > hierarchy (cgroup core internally calls it the default hierarchy as
> > this is the tree all the controllers are attached to by default).
> 
> I am not sure I understand. So they are visible only in the hierarchy
> mounted with the new cgroup API (sane or how is it called)?

Yeap.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
