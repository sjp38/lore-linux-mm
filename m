Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 9DAA16B005D
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 16:46:24 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9108006pbb.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:46:24 -0700 (PDT)
Date: Fri, 21 Sep 2012 13:46:19 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 00/16] slab accounting for memcg
Message-ID: <20120921204619.GR7264@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347977530-29755-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

Hello,

On Tue, Sep 18, 2012 at 06:11:54PM +0400, Glauber Costa wrote:
> This is a followup to the previous kmem series. I divided them logically
> so it gets easier for reviewers. But I believe they are ready to be merged
> together (although we can do a two-pass merge if people would prefer)
> 
> Throwaway git tree found at:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git kmemcg-slab
> 
> There are mostly bugfixes since last submission.
> 
> For a detailed explanation about this series, please refer to my previous post
> (Subj: [PATCH v3 00/13] kmem controller for memcg.)

In general, things look good to me.  I think the basic approach is
manageable and does a decent job of avoiding introducing complications
on the usual code paths.

Pekka seems generally happy with the approach too.  Christoph, what do
you think?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
