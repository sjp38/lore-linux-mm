Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id CBFF86B00C6
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:57:06 -0500 (EST)
Message-ID: <50B8D74E.7020808@parallels.com>
Date: Fri, 30 Nov 2012 19:57:02 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] cgroup: warn about broken hierarchies only after
 css_online
References: <1354282286-32278-1-git-send-email-glommer@parallels.com> <1354282286-32278-2-git-send-email-glommer@parallels.com> <20121130151158.GB3873@htj.dyndns.org> <50B8CD32.4080807@parallels.com> <20121130154504.GD3873@htj.dyndns.org> <20121130154912.GM29317@dhcp22.suse.cz>
In-Reply-To: <20121130154912.GM29317@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On 11/30/2012 07:49 PM, Michal Hocko wrote:
> On Fri 30-11-12 07:45:04, Tejun Heo wrote:
>> Hello, Glauber.
>>
>> On Fri, Nov 30, 2012 at 07:13:54PM +0400, Glauber Costa wrote:
>>>> Applied to cgroup/for-3.8.  Thanks!
>>>>
>>>
>>> We just need to be careful because when we merge it with morton's, more
>>> bits will need converting.
>>
>> This one is in cgrou proper and I think it should be safe, right?
>> Other ones will be difficult.  Not sure how to handle them ATM.  An
>> easy way out would be deferring to the next merge window as it's so
>> close anyway.  Michal?
> 
> yes, I think so as well. I guess the window will open soon.
> 
I vote for deferring as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
