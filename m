Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9A3C6B0253
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 19:46:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so18679637pfg.2
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 16:46:53 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id db4si5545262pad.90.2016.08.11.16.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 16:46:53 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id fi15so2941682pac.1
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 16:46:53 -0700 (PDT)
Date: Fri, 12 Aug 2016 09:47:13 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [RFC][PATCH] cgroup_threadgroup_rwsem - affects scalability and
 OOM
Message-ID: <20160811234713.GA22218@350D>
Reply-To: bsingharora@gmail.com
References: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
 <20160810194306.GP25053@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160810194306.GP25053@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Aug 10, 2016 at 03:43:06PM -0400, Tejun Heo wrote:
> Hello,
> 
> Edited subject and description and applied the patch to
> cgroup/for-4.8-fixes w/ stable cc'd.
>

Thanks, Found a typo below.. small nit
 
> Thanks.
> ------ 8< ------
<snip>
> This patch moves the threadgroup_change_begin from before
> cgroup_fork() to just before cgroup_canfork().  There is no nee to
							     ^ need
> worry about threadgroup changes till the task is actually added to the
> threadgroup.  This avoids having to call reclaim with
> cgroup_threadgroup_rwsem held.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
