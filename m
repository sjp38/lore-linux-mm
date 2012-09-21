Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id B0FEF6B0068
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 16:47:32 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9109766pbb.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:47:32 -0700 (PDT)
Date: Fri, 21 Sep 2012 13:47:27 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 00/16] slab accounting for memcg
Message-ID: <20120921204727.GS7264@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <20120921204619.GR7264@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120921204619.GR7264@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On Fri, Sep 21, 2012 at 01:46:19PM -0700, Tejun Heo wrote:
> In general, things look good to me.  I think the basic approach is
> manageable and does a decent job of avoiding introducing complications
> on the usual code paths.
> 
> Pekka seems generally happy with the approach too.  Christoph, what do
> you think?

Ooh, also, why aren't Andrew and Michal not cc'd?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
