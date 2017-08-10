Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 222156B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:34:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a186so2470945wmh.9
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 03:34:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si4941683wrp.61.2017.08.10.03.34.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 03:34:07 -0700 (PDT)
Date: Thu, 10 Aug 2017 12:34:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memcg Can't context between v1 and v2 because css->refcnt not
 released
Message-ID: <20170810103405.GL23863@dhcp22.suse.cz>
References: <CADK2BfzM9V=C3Kk6v714K3NVX58Q6pEaAMiHDGSyr6PakC2O=w@mail.gmail.com>
 <20170810071059.GC23863@dhcp22.suse.cz>
 <CADK2BfwC3WDGwoDPSjX1UpwP-4fDz5fSBjdENbxn5XQL8y3K3A@mail.gmail.com>
 <20170810081920.GG23863@dhcp22.suse.cz>
 <CADK2BfxJim8MvLPY497a+JAK2t9OTq+f1BY0o4qK0ihaWsoEMQ@mail.gmail.com>
 <CADK2BfzarAEQz=_Um23mywmdRvhNbe5OL_7k13XD3D5==nn0qg@mail.gmail.com>
 <CADK2Bfwxp3gSDrYXAxhgoYne2T=1_RyPXqQt_cGHz86dfWgsqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADK2Bfwxp3gSDrYXAxhgoYne2T=1_RyPXqQt_cGHz86dfWgsqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wang Yu <yuwang668899@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

[restoring the CC list]

On Thu 10-08-17 17:57:38, wang Yu wrote:
> 2017-08-10 17:28 GMT+08:00 wang Yu <yuwang668899@gmail.com>:
[...]
> > after drop caches, memory.stat  shows not pages belong the group, but
> > memory.usage_in_bytes not zero, so maybe other pages
> > has wrong to belong this group
>
> after drop cache, there maybe have kmem pages ,e.g. slab
> it can't free both drop cache or tasks free,
> so back this problem, without mem_cgroup_reparent_charges,
> cgroup v1 can't umount , and cgroup v2 can't mount

Ohh, right. It is true that there is no explicit control over kmem page
life time. I am afraid this is something non-trivial to address though.
I am not sure swithing between cgroup versions is a strong enough use
case to implement something like that but you can definitely try to do
that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
