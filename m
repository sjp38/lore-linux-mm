Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 90CFA6B0069
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 03:33:03 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so302965lbj.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 00:33:01 -0700 (PDT)
Date: Wed, 20 Jun 2012 10:32:50 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH v4 05/25] memcg: Always free struct memcg through
 schedule_work()
In-Reply-To: <4FDF1AAE.4080209@parallels.com>
Message-ID: <alpine.LFD.2.02.1206201031150.2989@tux.localdomain>
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-6-git-send-email-glommer@parallels.com> <4FDF1A0D.6080204@jp.fujitsu.com> <4FDF1AAE.4080209@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Mon, 18 Jun 2012, Glauber Costa wrote:
> I believe this is already in the -mm tree (from the sock memcg fixes)
> 
> But actually, my main trouble with this series here, is that I am basing
> it on Pekka's tree, while some of the fixes are in -mm already.
> If I'd base it on -mm I would lose some of the stuff as well.
> 
> Maybe Pekka can merge the current -mm with his tree?

I first want to have a stable base from Christoph's "common slab" series 
before I am comfortable with going forward with the memcg parts.

Feel free to push forward any preparational patches to the slab 
allocators, though.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
