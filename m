Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id AF28B6B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 04:42:53 -0400 (EDT)
Message-ID: <4FE18C6B.1020503@parallels.com>
Date: Wed, 20 Jun 2012 12:40:11 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 05/25] memcg: Always free struct memcg through schedule_work()
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-6-git-send-email-glommer@parallels.com> <4FDF1A0D.6080204@jp.fujitsu.com> <4FDF1AAE.4080209@parallels.com> <alpine.LFD.2.02.1206201031150.2989@tux.localdomain>
In-Reply-To: <alpine.LFD.2.02.1206201031150.2989@tux.localdomain>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 06/20/2012 11:32 AM, Pekka Enberg wrote:
>> >Maybe Pekka can merge the current -mm with his tree?
> I first want to have a stable base from Christoph's "common slab" series
> before I am comfortable with going forward with the memcg parts.
>
> Feel free to push forward any preparational patches to the slab
> allocators, though.
>
> 			Pekka

Kame and others:

If you are already comfortable with the general shape of the series, it 
would do me good to do the same with the memcg preparation patches, so 
we have less code to review and merge in the next window.

They are:

     memcg: Make it possible to use the stock for more than one page.
     memcg: Reclaim when more than one page needed.
     memcg: change defines to an enum

Do you see any value in merging them now ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
