Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E68E46B00F2
	for <linux-mm@kvack.org>; Thu, 17 May 2012 11:19:54 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3794257dak.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 08:19:54 -0700 (PDT)
Date: Thu, 17 May 2012 08:19:47 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Message-ID: <20120517151947.GI21275@google.com>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com>
 <1336767077-25351-3-git-send-email-glommer@parallels.com>
 <20120516140637.17741df6.akpm@linux-foundation.org>
 <4FB46B4C.3000307@parallels.com>
 <20120516223715.5d1b4385.akpm@linux-foundation.org>
 <4FB4CA4D.50608@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FB4CA4D.50608@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Thu, May 17, 2012 at 01:52:13PM +0400, Glauber Costa wrote:
> Andrew is right. It seems we will need that mutex after all. Just
> this is not a race, and neither something that should belong in the
> static_branch interface.

Yeah, with a completely different comment.  It just needs to wrap
->activated alteration and static key inc/dec, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
