Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id C22C86B0071
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:41:24 -0400 (EDT)
Received: by mail-ob0-f179.google.com with SMTP id wp4so47399obc.10
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 21:41:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o67si168004oif.33.2014.10.16.21.41.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 21:41:24 -0700 (PDT)
Date: Thu, 16 Oct 2014 21:42:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/5] mm: memcontrol: continue cache reclaim from
 offlined groups
Message-Id: <20141016214240.ade3712f.akpm@linux-foundation.org>
In-Reply-To: <20141017030221.GA8506@phnom.home.cmpxchg.org>
References: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
	<1413303637-23862-5-git-send-email-hannes@cmpxchg.org>
	<20141015152555.GI23547@dhcp22.suse.cz>
	<20141017030221.GA8506@phnom.home.cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 16 Oct 2014 23:02:21 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Andrew, could you update the changelog in place to have that paragraph
> read
> 
> Since c2931b70a32c ("cgroup: iterate cgroup_subsys_states directly")
> css iterators now also include offlined css, so memcg iterators can be
> changed to include offlined children during reclaim of a group, and
> leftover cache can just stay put.

Done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
