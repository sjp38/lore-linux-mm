Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A1E9F6B005A
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 03:07:13 -0400 (EDT)
Message-ID: <502DECE2.9090402@parallels.com>
Date: Fri, 17 Aug 2012 11:04:02 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 06/11] memcg: kmem controller infrastructure
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-7-git-send-email-glommer@parallels.com> <50254475.4000201@jp.fujitsu.com> <5028BA9E.7000302@parallels.com> <502DAE2A.1000404@jp.fujitsu.com>
In-Reply-To: <502DAE2A.1000404@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On 08/17/2012 06:36 AM, Kamezawa Hiroyuki wrote:
> I just want to see the same logic used in mem_cgroup_uncharge_common().
> Hmm, at setting pc->mem_cgroup, the things happens in
>    set pc->mem_cgroup
>    set Used bit
> order. If you clear pc->mem_cgroup
>    unset Used bit
>    clear pc->mem_cgroup
> seems reasonable.

Makes sense. I'll make sure we're consistent here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
