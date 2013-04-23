Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 846A96B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 14:04:39 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so648740pad.39
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 11:04:38 -0700 (PDT)
Date: Tue, 23 Apr 2013 13:11:22 -0400
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
Message-ID: <20130423171122.GA29983@teo>
References: <1366705329-9426-1-git-send-email-glommer@openvz.org>
 <1366705329-9426-2-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1366705329-9426-2-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Apr 23, 2013 at 12:22:08PM +0400, Glauber Costa wrote:
> From: Glauber Costa <glommer@parallels.com>
[...]
> This patch extends that to also support in-kernel users.

Yup, that is the next logical step. ;-) The patches look good to me, just
one question...

> @@ -227,7 +233,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
>  	 * we account it too.
>  	 */
>  	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))

I wonder if we want to let kernel users to specify the gfp mask here? The
current mask is good for userspace notifications, but in-kernel users
might be interested in including (or excluding) different types of
allocations, e.g. watch only for DMA allocations pressure?

Thanks!

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
