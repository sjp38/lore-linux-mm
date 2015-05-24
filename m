Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6236B00E0
	for <linux-mm@kvack.org>; Sun, 24 May 2015 17:24:44 -0400 (EDT)
Received: by qgf2 with SMTP id 2so3561559qgf.3
        for <linux-mm@kvack.org>; Sun, 24 May 2015 14:24:44 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id 19si4875342qkt.64.2015.05.24.14.24.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 May 2015 14:24:43 -0700 (PDT)
Received: by qkx62 with SMTP id 62so51862948qkx.3
        for <linux-mm@kvack.org>; Sun, 24 May 2015 14:24:43 -0700 (PDT)
Date: Sun, 24 May 2015 17:24:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 11/51] memcg: implement mem_cgroup_css_from_page()
Message-ID: <20150524212440.GD7099@htj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-12-git-send-email-tj@kernel.org>
 <20150522232831.GB6485@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522232831.GB6485@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello,

On Fri, May 22, 2015 at 07:28:31PM -0400, Johannes Weiner wrote:
> replace_page_cache() can clear page->mem_cgroup even when the page
> still has references, so unfortunately you must hold the page lock
> when calling this function.
> 
> I haven't checked how you use this - chances are you always have the
> page locked anyways - but it probably needs a comment.

Hmmm... as replace_page_cache_page() is used only by fuse and fuse's
bdi doesn't go through the usual writeback accounting which is
necessary for cgroup writeback support anyway, so I don't think this
presents an actual problem.  I'll add a warning in
replace_page_cache_page() which triggers when it's used on a bdi which
has cgroup writeback enabled and add comments explaining what's going
on.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
