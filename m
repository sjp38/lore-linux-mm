Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 818E86B00E7
	for <linux-mm@kvack.org>; Wed, 16 May 2012 02:12:36 -0400 (EDT)
Message-ID: <4FB344D0.8050309@parallels.com>
Date: Wed, 16 May 2012 10:10:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/29] slub: fix slab_state for slub
References: <1336758272-24284-1-git-send-email-glommer@parallels.com> <1336758272-24284-3-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205151453460.18595@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1205151453460.18595@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Christoph Lameter <cl@linux.com>

On 05/16/2012 01:55 AM, David Rientjes wrote:
> On Fri, 11 May 2012, Glauber Costa wrote:
>
>> When the slub code wants to know if the sysfs state has already been
>> initialized, it tests for slab_state == SYSFS. This is quite fragile,
>> since new state can be added in the future (it is, in fact, for
>> memcg caches). This patch fixes this behavior so the test matches
>>> = SYSFS, as all other state does.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>
> Acked-by: David Rientjes<rientjes@google.com>
>
> Can be merged now, there's no dependency on the rest of this patchset.

Agreed.

If anyone is willing to, would make my life easier in the future.

Valid for all patches that fall in this category (there are quite a few 
in the purely memcg land as well)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
