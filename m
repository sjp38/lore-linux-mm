Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3E082963
	for <linux-mm@kvack.org>; Thu, 12 May 2016 12:03:25 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u185so131538844oie.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 09:03:25 -0700 (PDT)
Received: from mail-ig0-x244.google.com (mail-ig0-x244.google.com. [2607:f8b0:4001:c05::244])
        by mx.google.com with ESMTPS id h7si14293083igr.16.2016.05.12.09.03.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 09:03:24 -0700 (PDT)
Received: by mail-ig0-x244.google.com with SMTP id c3so126737igl.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 09:03:24 -0700 (PDT)
Date: Thu, 12 May 2016 12:03:22 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] Documentation/memcg: update kmem limit doc as codes
 behavior
Message-ID: <20160512160322.GU4775@htj.duckdns.org>
References: <572B0105.50503@huawei.com>
 <20160505083221.GD4386@dhcp22.suse.cz>
 <5732CC23.2060101@huawei.com>
 <20160511064018.GB16677@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160511064018.GB16677@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Qiang Huang <h.huangqiang@huawei.com>, corbet@lwn.net, Zefan Li <lizefan@huawei.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, May 11, 2016 at 08:40:19AM +0200, Michal Hocko wrote:
> On Wed 11-05-16 14:07:31, Qiang Huang wrote:
> > The restriction of kmem setting is not there anymore because the
> > accounting is enabled by default even in the cgroup v1 - see
> > b313aeee2509 ("mm: memcontrol: enable kmem accounting for all
> > cgroups in the legacy hierarchy").
> > 
> > Update docs accordingly.
> 
> I am pretty sure there will be other things out of date in that file but
> this is an improvemtn already.
> 
> > Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Andrew, can you please pick this one up?

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
