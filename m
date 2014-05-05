Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id E070B6B00C7
	for <linux-mm@kvack.org>; Mon,  5 May 2014 17:36:49 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id w10so7367329pde.5
        for <linux-mm@kvack.org>; Mon, 05 May 2014 14:36:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ug9si9789314pab.376.2014.05.05.14.36.48
        for <linux-mm@kvack.org>;
        Mon, 05 May 2014 14:36:48 -0700 (PDT)
Date: Mon, 5 May 2014 14:36:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/memcontrol.c: introduce helper
 mem_cgroup_zoneinfo_zone()
Message-Id: <20140505143646.c0591119522b869b79d9c77b@linux-foundation.org>
In-Reply-To: <20140502232908.GQ23420@cmpxchg.org>
References: <1397862103-31982-1-git-send-email-nasa4836@gmail.com>
	<20140422095923.GD29311@dhcp22.suse.cz>
	<20140428150426.GB24807@dhcp22.suse.cz>
	<20140501125450.GA23420@cmpxchg.org>
	<20140502150516.d42792bad53d86fb727816bd@linux-foundation.org>
	<20140502232908.GQ23420@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Jianyu Zhan <nasa4836@gmail.com>, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.com

On Fri, 2 May 2014 19:29:08 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Memcg zoneinfo lookup sites have either the page, the zone, or the
> node id and zone index, but sites that only have the zone have to look
> up the node id and zone index themselves, whereas sites that already
> have those two integers use a function for a simple pointer chase.
> 
> Provide mem_cgroup_zone_zoneinfo() that takes a zone pointer and let
> sites that already have node id and zone index - all for each node,
> for each zone iterators - use &memcg->nodeinfo[nid]->zoneinfo[zid].
> 
> Rename page_cgroup_zoneinfo() to mem_cgroup_page_zoneinfo() to match.

Patch shrinks my mm/memcontrol.o nicely:

   text    data     bss     dec     hex filename
  55702   15681   24560   95943   176c7 mm/memcontrol.o-before
  55489   15681   24464   95634   17592 mm/memcontrol.o-after

The bss size changes are weird - the patch doesn't touch bss afaict. 
This often happens.  One day I'll get in there and work out why.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
