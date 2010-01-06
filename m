Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF0696B003D
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 22:08:00 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id o062b2nb008221
	for <linux-mm@kvack.org>; Wed, 6 Jan 2010 08:07:02 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0637tNq3821622
	for <linux-mm@kvack.org>; Wed, 6 Jan 2010 08:37:55 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0637twb026775
	for <linux-mm@kvack.org>; Wed, 6 Jan 2010 14:07:55 +1100
Date: Wed, 6 Jan 2010 08:37:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mm] Shared Page accounting for memory cgroup (v2)
Message-ID: <20100106030752.GI3059@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100105185226.GG3059@balbir.in.ibm.com>
 <20100106090708.f3ec9fd8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100106090708.f3ec9fd8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-06 09:07:08]:

> On Wed, 6 Jan 2010 00:22:26 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Hi, All,
> > 
> > No major changes from v1, except for the use of get_mm_rss().
> > Kamezawa-San felt that this can be done in user space and I responded
> > to him with my concerns of doing it in user space. The thread
> > can be found at http://thread.gmane.org/gmane.linux.kernel.mm/42367.
> > 
> > If there are no major objections, can I ask for a merge into -mm.
> > Andrew, the patches are against mmotm 10 December 2009, if there
> > are some merge conflicts, please let me know, I can rebase after
> > you release the next mmotm.
> > 
> 
> The problem is that this isn't "shared" uasge but "considered to be shared"
> usage. Okay ?
>

Could you give me your definition of "shared". From the mem cgroup
perspective, total_rss (which is accumulated) subtracted from the
count of pages in the LRU which are RSS and FILE_MAPPED is shared, no?
I understand that some of the pages that might be shared, show up
in our LRU and accounting. These are not treated as shared by
our cgroup, but by other cgroups.
 
> Then I don't want to provide this misleading value as "official report" from
> the kernel. And this can be done in userland.
>

I explained some of the issues of doing this from user space, would
you be OK if I called them "non-private" pages?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
