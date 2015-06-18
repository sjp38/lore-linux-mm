Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 81E666B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 13:49:34 -0400 (EDT)
Received: by qgeu36 with SMTP id u36so28597949qge.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 10:49:34 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id f31si8374110qkh.15.2015.06.18.10.49.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 10:49:33 -0700 (PDT)
Received: by qkhu186 with SMTP id u186so48086391qkh.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 10:49:33 -0700 (PDT)
Date: Thu, 18 Jun 2015 13:49:30 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 06/51] memcg: add mem_cgroup_root_css
Message-ID: <20150618174930.GA12934@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-7-git-send-email-tj@kernel.org>
 <20150617145642.GI25056@dhcp22.suse.cz>
 <20150617182500.GI22637@mtj.duckdns.org>
 <20150618111227.GA5858@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150618111227.GA5858@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello, Michal.

On Thu, Jun 18, 2015 at 01:12:27PM +0200, Michal Hocko wrote:
...
> I see and yes, it makes some sense. I just think we can get rid of the
> accessor functions when the struct mem_cgroup is visible and the code
> can simply do &{page->}mem_cgroup->css.

As long as the accessors are inline, I think it should be fine.

> I have tried to compile with !CONFIG_MEMCG and !CONFIG_CGROUP_WRITEBACK
> without mem_cgroup_root_css defined for this configuration and
> mm/backing-dev.c compiles just fine. So maybe we should get rid of it
> rather than have a potentially tricky code?

Yeah, please feel free to queue a patch to remove it if doesn't break
anything.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
