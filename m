Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f177.google.com (mail-gg0-f177.google.com [209.85.161.177])
	by kanga.kvack.org (Postfix) with ESMTP id F26706B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:14:20 -0500 (EST)
Received: by mail-gg0-f177.google.com with SMTP id 4so60100ggm.36
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:14:20 -0800 (PST)
Received: from mail-gg0-x22d.google.com (mail-gg0-x22d.google.com [2607:f8b0:4002:c02::22d])
        by mx.google.com with ESMTPS id e7si14444186qez.36.2013.12.17.05.14.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 05:14:19 -0800 (PST)
Received: by mail-gg0-f173.google.com with SMTP id q4so61367ggn.32
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:14:18 -0800 (PST)
Date: Tue, 17 Dec 2013 08:14:15 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
Message-ID: <20131217131415.GG29989@htj.dyndns.org>
References: <52AEC989.4080509@huawei.com>
 <20131216095345.GB23582@dhcp22.suse.cz>
 <20131216104042.GC23582@dhcp22.suse.cz>
 <20131216163530.GH32509@htj.dyndns.org>
 <20131216171937.GG26797@dhcp22.suse.cz>
 <20131216172143.GJ32509@htj.dyndns.org>
 <alpine.LNX.2.00.1312161718001.2037@eggly.anvils>
 <52AFC163.5010507@huawei.com>
 <alpine.LNX.2.00.1312162300410.16426@eggly.anvils>
 <20131217131119.GD28991@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217131119.GD28991@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 17, 2013 at 02:11:19PM +0100, Michal Hocko wrote:
> And sorry for distracting you from the css based approach. I have
> totally misinterpreted the comment above idr_remove.

Heh, you actually interpreted it correctly.  I was the one confused
when moving the id to cgroup.  I should have just converted css_id to
idr based per-subsys id in the first place.  Sorry about that. :)

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
