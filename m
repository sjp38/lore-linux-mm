Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2F82B6B0182
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 01:36:01 -0400 (EDT)
Date: Thu, 8 Sep 2011 08:35:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 3/9] socket: initial cgroup code.
Message-ID: <20110908053558.GA9464@shutemov.name>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com>
 <1315369399-3073-4-git-send-email-glommer@parallels.com>
 <20110907221710.GA7845@shutemov.name>
 <4E684A6B.6030205@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E684A6B.6030205@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, xemul@parallels.com, netdev@vger.kernel.org, linux-mm@kvack.org, "Eric W. Biederman" <ebiederm@xmission.com>, containers@lists.osdl.org, "David S. Miller" <davem@davemloft.net>

On Thu, Sep 08, 2011 at 01:54:03AM -0300, Glauber Costa wrote:
> On 09/07/2011 07:17 PM, Kirill A. Shutemov wrote:
> > On Wed, Sep 07, 2011 at 01:23:13AM -0300, Glauber Costa wrote:
> >> We aim to control the amount of kernel memory pinned at any
> >> time by tcp sockets. To lay the foundations for this work,
> >> this patch adds a pointer to the kmem_cgroup to the socket
> >> structure.
> >>
> >> Signed-off-by: Glauber Costa<glommer@parallels.com>
> >> CC: David S. Miller<davem@davemloft.net>
> >> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
> >> CC: Eric W. Biederman<ebiederm@xmission.com>
> >> ---
> >>   include/linux/kmem_cgroup.h |   29 +++++++++++++++++++++++++++++
> >>   include/net/sock.h          |    2 ++
> >>   net/core/sock.c             |    5 ++---
> >>   3 files changed, 33 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/include/linux/kmem_cgroup.h b/include/linux/kmem_cgroup.h
> >> index 0e4a74b..77076d8 100644
> >> --- a/include/linux/kmem_cgroup.h
> >> +++ b/include/linux/kmem_cgroup.h
> >> @@ -49,5 +49,34 @@ static inline struct kmem_cgroup *kcg_from_task(struct task_struct *tsk)
> >>   	return NULL;
> >>   }
> >>   #endif /* CONFIG_CGROUP_KMEM */
> >> +
> >> +#ifdef CONFIG_INET
> >
> > Will it break something if you define the helpers even if CONFIG_INET
> > is not defined?
> > It will be much cleaner. You can reuse ifdef CONFIG_CGROUP_KMEM in this
> > case.
> 
> The helpers inside CONFIG_INET are needed for the network code, 
> regardless of kmem cgroup is defined or not, not the other way around.
> 
> So I could remove CONFIG_INET, but I can't possibly move it inside
> CONFIG_CGROUP_KMEM. So this buy us nothing.

You can define empty under CONFIG_CGROUP_KMEM's #else, can't you?
Like with kcg_from_cgroup()/kcg_from_task().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
