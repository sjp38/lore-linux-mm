Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 0EB6A6B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 13:30:03 -0400 (EDT)
Date: Fri, 10 Aug 2012 19:30:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 02/11] memcg: Reclaim when more than one page needed.
Message-ID: <20120810173000.GB14591@dhcp22.suse.cz>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
 <1344517279-30646-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344517279-30646-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Suleiman Souhlal <suleiman@google.com>

On Thu 09-08-12 17:01:10, Glauber Costa wrote:
[...]
> For now retry up to COSTLY_ORDER (as page_alloc.c does) and make sure
> not to do it if __GFP_NORETRY.

Who is using __GFP_NORETRY for user backed memory (except for hugetlb
which has its own controller)?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
