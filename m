Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 1B65A6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 08:08:28 -0500 (EST)
Message-ID: <50FD3DD4.5050309@parallels.com>
Date: Mon, 21 Jan 2013 17:08:36 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 6/6] memcg: avoid dangling reference count in creation
 failure.
References: <1358766813-15095-1-git-send-email-glommer@parallels.com> <1358766813-15095-7-git-send-email-glommer@parallels.com> <20130121123057.GH7798@dhcp22.suse.cz>
In-Reply-To: <20130121123057.GH7798@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On 01/21/2013 04:30 PM, Michal Hocko wrote:
> On Mon 21-01-13 15:13:33, Glauber Costa wrote:
>> When use_hierarchy is enabled, we acquire an extra reference count
>> in our parent during cgroup creation. We don't release it, though,
>> if any failure exist in the creation process.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> Reported-by: Michal Hocko <mhocko@suse>
> 
> If you put this one to the head of the series we can backport it to
> stable which is preferred, although nobody have seen this as a problem.
> 
If I have to send again, I might. But I see no reason to do so otherwise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
