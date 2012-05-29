Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 116E46B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 13:29:24 -0400 (EDT)
Message-ID: <4FC506E6.8030108@parallels.com>
Date: Tue, 29 May 2012 21:27:02 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 13/28] slub: create duplicate cache
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-14-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205290932530.4666@router.home> <4FC4F1A7.2010206@parallels.com> <alpine.DEB.2.00.1205291101580.6723@router.home> <4FC501E9.60607@parallels.com> <alpine.DEB.2.00.1205291222360.8495@router.home>
In-Reply-To: <alpine.DEB.2.00.1205291222360.8495@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/29/2012 09:25 PM, Christoph Lameter wrote:
>> I will try to at least have the page accounting done in a consistent way. How
>> >  about that?
> Ok. What do you mean by "consistent"? Since objects and pages can be used
> in a shared way and since accounting in many areas of the kernel is
> intentional fuzzy to avoid performance issues there is not that much of a
> requirement for accuracy. We have problems even just defining what the
> exact set of pages belonging to a task/process is.
>
I mean consistent between allocators, done in a shared place.
Note that what we do here *is* still fuzzy to some degree. We can have a 
level of sharing, and always account to the first one to touch, we don't 
go worrying about this because that would be hell. We also don't
carry a process' objects around when we send it to a different cgroup. 
Those are all already simplications for performance and simplicity sake.

But we really need a page to be filled with objects from the same 
cgroup, and the non-shared objects to be accounted to the right place.

Otherwise, I don't think we can meet even the lighter of isolation 
guarantees.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
