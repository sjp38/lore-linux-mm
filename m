Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id A37D16B00C6
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 05:13:54 -0400 (EDT)
Message-ID: <506AAF7F.9030901@parallels.com>
Date: Tue, 2 Oct 2012 13:10:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 03/13] memcg: change defines to an enum
References: <1347977050-29476-1-git-send-email-glommer@parallels.com> <1347977050-29476-4-git-send-email-glommer@parallels.com> <20121001190652.GD23734@cmpxchg.org>
In-Reply-To: <20121001190652.GD23734@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On 10/01/2012 11:06 PM, Johannes Weiner wrote:
> On Tue, Sep 18, 2012 at 06:04:00PM +0400, Glauber Costa wrote:
>> This is just a cleanup patch for clarity of expression.  In earlier
>> submissions, people asked it to be in a separate patch, so here it is.
>>
>> [ v2: use named enum as type throughout the file as well ]
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> Acked-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> Should probably be the first in the series to get the cleanups out of
> the way :-)
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
If you guys want to merge this separately, be my guest =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
