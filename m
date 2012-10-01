Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 33DC46B005D
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 08:46:39 -0400 (EDT)
Message-ID: <50698FD9.2040808@parallels.com>
Date: Mon, 1 Oct 2012 16:43:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 09/13] memcg: kmem accounting lifecycle management
References: <1347977050-29476-1-git-send-email-glommer@parallels.com> <1347977050-29476-10-git-send-email-glommer@parallels.com> <20121001121553.GG8622@dhcp22.suse.cz> <50698C97.70703@parallels.com> <20121001123654.GJ8622@dhcp22.suse.cz>
In-Reply-To: <20121001123654.GJ8622@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Johannes Weiner <hannes@cmpxchg.org>

On 10/01/2012 04:36 PM, Michal Hocko wrote:
> On Mon 01-10-12 16:29:11, Glauber Costa wrote:
>> On 10/01/2012 04:15 PM, Michal Hocko wrote:
>>> Based on the previous discussions I guess this one will get reworked,
>>> right?
>>>
>>
>> Yes, but most of it stayed. The hierarchy part is gone, but because we
>> will still have kmem pages floating around (potentially), I am still
>> using the mark_dead() trick with the corresponding get when kmem_accounted.
> 
> Is it OK if I hold on with the review of this one until the next
> version?
> 
Of course.

I haven't sent it yet because I also received a lot more feedback for
the slab part (which is expected), and I want to get a least part of
that going before I send it again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
