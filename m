Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3F41C6B0085
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 05:18:54 -0400 (EDT)
Received: by wgfq1 with SMTP id q1so37811825wgf.1
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 02:18:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x6si18766864wjy.114.2015.06.19.02.18.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 02:18:53 -0700 (PDT)
Date: Fri, 19 Jun 2015 11:18:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 06/51] memcg: add mem_cgroup_root_css
Message-ID: <20150619091848.GE4913@dhcp22.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-7-git-send-email-tj@kernel.org>
 <20150617145642.GI25056@dhcp22.suse.cz>
 <20150617182500.GI22637@mtj.duckdns.org>
 <20150618111227.GA5858@dhcp22.suse.cz>
 <20150618174930.GA12934@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150618174930.GA12934@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Thu 18-06-15 13:49:30, Tejun Heo wrote:
[...]
> > I have tried to compile with !CONFIG_MEMCG and !CONFIG_CGROUP_WRITEBACK
> > without mem_cgroup_root_css defined for this configuration and
> > mm/backing-dev.c compiles just fine. So maybe we should get rid of it
> > rather than have a potentially tricky code?
> 
> Yeah, please feel free to queue a patch to remove it if doesn't break
> anything.

Against which branch should a I generate the patch?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
