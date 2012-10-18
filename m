Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 53F226B005A
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 05:38:21 -0400 (EDT)
Message-ID: <507FCE00.1090501@parallels.com>
Date: Thu, 18 Oct 2012 13:38:08 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 14/14] Add documentation about the kmem controller
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-15-git-send-email-glommer@parallels.com> <20121017151254.e26607c5.akpm@linux-foundation.org>
In-Reply-To: <20121017151254.e26607c5.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 10/18/2012 02:12 AM, Andrew Morton wrote:
> On Tue, 16 Oct 2012 14:16:51 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>> +Kernel memory won't be accounted at all until limit on a group is set. This
>> +allows for existing setups to continue working without disruption.  The limit
>> +cannot be set if the cgroup have children, or if there are already tasks in the
>> +cgroup.
> 
> What behaviour will usersapce see if "The limit cannot be set"? 
> write() returns -EINVAL, something like that?
> 
-EBUSY.

Will update.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
