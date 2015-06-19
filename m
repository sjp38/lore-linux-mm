Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id A1B736B0092
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 11:17:24 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so62535747qkh.0
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 08:17:24 -0700 (PDT)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com. [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id b108si11145100qgf.111.2015.06.19.08.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jun 2015 08:17:23 -0700 (PDT)
Received: by qcmc1 with SMTP id c1so3699553qcm.2
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 08:17:23 -0700 (PDT)
Date: Fri, 19 Jun 2015 11:17:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 06/51] memcg: add mem_cgroup_root_css
Message-ID: <20150619151719.GI12934@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-7-git-send-email-tj@kernel.org>
 <20150617145642.GI25056@dhcp22.suse.cz>
 <20150617182500.GI22637@mtj.duckdns.org>
 <20150618111227.GA5858@dhcp22.suse.cz>
 <20150618174930.GA12934@mtj.duckdns.org>
 <20150619091848.GE4913@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150619091848.GE4913@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri, Jun 19, 2015 at 11:18:48AM +0200, Michal Hocko wrote:
> On Thu 18-06-15 13:49:30, Tejun Heo wrote:
> [...]
> > > I have tried to compile with !CONFIG_MEMCG and !CONFIG_CGROUP_WRITEBACK
> > > without mem_cgroup_root_css defined for this configuration and
> > > mm/backing-dev.c compiles just fine. So maybe we should get rid of it
> > > rather than have a potentially tricky code?
> > 
> > Yeah, please feel free to queue a patch to remove it if doesn't break
> > anything.
> 
> Against which branch should a I generate the patch?

It's in the for-4.2/writeback branch of the block tree; however, a
patch against -mm should work, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
