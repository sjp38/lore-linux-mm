Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EC4BF6B004D
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 16:19:19 -0400 (EDT)
Date: Thu, 17 Sep 2009 22:15:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: cgrooups && 2.6.32 -mm merge plans
Message-ID: <20090917201516.GA29346@redhat.com>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090915161535.db0a6904.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, bblum@google.com, ebiederm@xmission.com, lizf@cn.fujitsu.com, matthltc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 09/15, Andrew Morton wrote:
>
> #cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup.patch: Oleg conniptions
> cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup.patch
> cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup-fix.patch
> cgroups-add-ability-to-move-all-threads-in-a-process-to-a-new-cgroup-atomically.patch
>
>   Merge after checking with Oleg.

Well. I think these patches are buggy :/

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
