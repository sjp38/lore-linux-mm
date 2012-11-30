Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 61AC06B00B9
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:14:08 -0500 (EST)
Message-ID: <50B8CD32.4080807@parallels.com>
Date: Fri, 30 Nov 2012 19:13:54 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] cgroup: warn about broken hierarchies only after
 css_online
References: <1354282286-32278-1-git-send-email-glommer@parallels.com> <1354282286-32278-2-git-send-email-glommer@parallels.com> <20121130151158.GB3873@htj.dyndns.org>
In-Reply-To: <20121130151158.GB3873@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 11/30/2012 07:11 PM, Tejun Heo wrote:
> On Fri, Nov 30, 2012 at 05:31:23PM +0400, Glauber Costa wrote:
>> If everything goes right, it shouldn't really matter if we are spitting
>> this warning after css_alloc or css_online. If we fail between then,
>> there are some ill cases where we would previously see the message and
>> now we won't (like if the files fail to be created).
>>
>> I believe it really shouldn't matter: this message is intended in spirit
>> to be shown when creation succeeds, but with insane settings.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
> 
> Applied to cgroup/for-3.8.  Thanks!
> 

We just need to be careful because when we merge it with morton's, more
bits will need converting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
