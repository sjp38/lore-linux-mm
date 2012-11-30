Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id DEE536B00B7
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:12:04 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so517702pbc.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 07:12:04 -0800 (PST)
Date: Fri, 30 Nov 2012 07:11:58 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/4] cgroup: warn about broken hierarchies only after
 css_online
Message-ID: <20121130151158.GB3873@htj.dyndns.org>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354282286-32278-2-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Fri, Nov 30, 2012 at 05:31:23PM +0400, Glauber Costa wrote:
> If everything goes right, it shouldn't really matter if we are spitting
> this warning after css_alloc or css_online. If we fail between then,
> there are some ill cases where we would previously see the message and
> now we won't (like if the files fail to be created).
> 
> I believe it really shouldn't matter: this message is intended in spirit
> to be shown when creation succeeds, but with insane settings.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>

Applied to cgroup/for-3.8.  Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
