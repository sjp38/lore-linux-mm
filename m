Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 055D76B006E
	for <linux-mm@kvack.org>; Wed, 27 May 2015 13:48:23 -0400 (EDT)
Received: by qkoo18 with SMTP id o18so10140872qko.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 10:48:22 -0700 (PDT)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id u2si18662820qhd.75.2015.05.27.10.48.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 10:48:21 -0700 (PDT)
Received: by qgg60 with SMTP id 60so6506388qgg.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 10:48:21 -0700 (PDT)
Date: Wed, 27 May 2015 13:48:17 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 11/51] memcg: implement mem_cgroup_css_from_page()
Message-ID: <20150527174817.GP7099@htj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-12-git-send-email-tj@kernel.org>
 <20150527161344.GO7099@htj.duckdns.org>
 <20150527170955.GA25324@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150527170955.GA25324@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello,

On Wed, May 27, 2015 at 01:09:55PM -0400, Johannes Weiner wrote:
> Regular page migration uses mem_cgroup_migrate() as well, but it's not
> a problem as it ensures that the old page doesn't have any outstanding
> references at that point.

Ooh, I see.

> It's only replace_page_cache_page() that calls mem_cgroup_migrate() on
> a live page breaking mem_cgroup_css_from_page().
> 
> So the page looks fine, I'd just update the culprit function in the
> changelog and kerneldoc.

Alright, will update the comment and description.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
