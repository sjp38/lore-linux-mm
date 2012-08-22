Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 41BDA6B0068
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 04:39:30 -0400 (EDT)
Message-ID: <50349A01.5020906@parallels.com>
Date: Wed, 22 Aug 2012 12:36:17 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 10/11] memcg: allow a memcg with kmem charges to be
 destructed.
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-11-git-send-email-glommer@parallels.com> <20120821082259.GB19797@dhcp22.suse.cz>
In-Reply-To: <20120821082259.GB19797@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 08/21/2012 12:22 PM, Michal Hocko wrote:
> On Thu 09-08-12 17:01:18, Glauber Costa wrote:
>> Because the ultimate goal of the kmem tracking in memcg is to track slab
>> pages as well, we can't guarantee that we'll always be able to point a
>> page to a particular process, and migrate the charges along with it -
>> since in the common case, a page will contain data belonging to multiple
>> processes.
>>
>> Because of that, when we destroy a memcg, we only make sure the
>> destruction will succeed by discounting the kmem charges from the user
>> charges when we try to empty the cgroup.
> 
> This changes the semantic of memory.force_empty file because the usage
> should be 0 on success but it will show kmem usage in fact now. I guess
> it is inevitable with u+k accounting so you should be explicit about
> that and also update the documentation.
aaand, it's done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
