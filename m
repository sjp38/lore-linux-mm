Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 9B5126B0083
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 11:33:53 -0500 (EST)
Date: Wed, 2 Jan 2013 16:33:52 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] retry slab allocation after first failure
In-Reply-To: <1355925702-7537-1-git-send-email-glommer@parallels.com>
Message-ID: <0000013bfc1c9ded-3caab903-961f-412b-9187-ad94a00a31f8-000000@email.amazonses.com>
References: <1355925702-7537-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Wed, 19 Dec 2012, Glauber Costa wrote:
>Dave Shrinnker <david@fromorbit.com>,

Hehehe. Hopefully the email address at least works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
