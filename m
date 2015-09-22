Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1936B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:24:39 -0400 (EDT)
Received: by obbda8 with SMTP id da8so7021432obb.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 06:24:39 -0700 (PDT)
Received: from m12-12.163.com (m12-12.163.com. [220.181.12.12])
        by mx.google.com with ESMTP id n4si952351obq.58.2015.09.22.06.24.36
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 06:24:38 -0700 (PDT)
Date: Tue, 22 Sep 2015 21:15:53 +0800
From: Yaowei Bai <bywxiaobai@163.com>
Subject: Re: [PATCH 1/3] mm/vmscan: make inactive_anon_is_low_global return
 directly
Message-ID: <20150922131553.GA4221@bbox>
References: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
 <20150921161806.GE19811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150921161806.GE19811@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 21, 2015 at 06:18:07PM +0200, Michal Hocko wrote:
> On Wed 16-09-15 19:59:58, Yaowei Bai wrote:
> > Delete unnecessary if to let inactive_anon_is_low_global return
> > directly.
> > 
> > No functional changes.
> 
> Is this really an improvement? I am not so sure. If anything the
> function has a bool return semantic...

Just FYI, I also sent a patch making inactive_anon_is_low_global return
bool and it has been added into Andrew's -mm tree.

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
