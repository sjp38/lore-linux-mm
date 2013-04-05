Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id BEDCC6B0006
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 04:09:29 -0400 (EDT)
Message-ID: <515E86DA.1090907@parallels.com>
Date: Fri, 5 Apr 2013 12:10:02 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 5/7] cgroup: make sure parent won't be destroyed
 before its children
References: <515BF233.6070308@huawei.com> <515BF2A4.1070703@huawei.com> <20130404113750.GH29911@dhcp22.suse.cz> <20130404133706.GA9425@htj.dyndns.org> <20130404152028.GK29911@dhcp22.suse.cz> <20130404152213.GL9425@htj.dyndns.org>
In-Reply-To: <20130404152213.GL9425@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 04/04/2013 07:22 PM, Tejun Heo wrote:
> On Thu, Apr 04, 2013 at 05:20:28PM +0200, Michal Hocko wrote:
>>> But what harm does an additional reference do?
>>
>> No harm at all. I just wanted to be sure that this is not yet another
>> "for memcg" hack. So if this is useful for other controllers then I have
>> no objections of course.
> 
> I think it makes sense in general, so let's do it in cgroup core.  I
> suppose it'd be easier for this to be routed together with other memcg
> changes?
> 
> Thanks.
> 
You guys seems already settled, but FWIW I agree with Tejun here. It
makes sense from a design point of view for a cgroup to pin its parent.
cgroup core it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
