Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4306B0098
	for <linux-mm@kvack.org>; Mon, 25 May 2015 12:06:30 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so43834361wic.1
        for <linux-mm@kvack.org>; Mon, 25 May 2015 09:06:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a14si13273942wib.49.2015.05.25.09.06.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 May 2015 09:06:28 -0700 (PDT)
Date: Mon, 25 May 2015 18:06:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150525160626.GC19389@dhcp22.suse.cz>
References: <20150519212754.GO24861@htj.duckdns.org>
 <20150520131044.GA28678@dhcp22.suse.cz>
 <20150520132158.GB28678@dhcp22.suse.cz>
 <20150520175302.GA7287@redhat.com>
 <20150520202221.GD14256@dhcp22.suse.cz>
 <20150521192716.GA21304@redhat.com>
 <20150522093639.GE5109@dhcp22.suse.cz>
 <20150522162900.GA8955@redhat.com>
 <20150522165734.GH5109@dhcp22.suse.cz>
 <20150522183042.GF26770@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522183042.GF26770@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Fri 22-05-15 20:30:42, Oleg Nesterov wrote:
> On 05/22, Michal Hocko wrote:
> >
> > On Fri 22-05-15 18:29:00, Oleg Nesterov wrote:
> > >
> > > In the likely case (if CLONE_VM without CLONE_THREAD was not used) the
> > > last for_each_process() in mm_update_next_owner() will find another thread
> > > from the same group.
> >
> > My understanding was that for_each_process will iterate only over
> > processes (represented by the thread group leaders).
> 
> Yes. But note the inner for_each_thread() loop. And note that we
> we need this loop exactly because the leader can be zombie.

I was too vague, sorry about that. What I meant was that
for_each_process would pick up a group leader and the inner
for_each_thread will return it as the first element in the list. As the
leader waits for other threads then it should stay on the thread_node
list as well. But I might be easily wrong here because the whole thing
is really quite confusing to be honest.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
