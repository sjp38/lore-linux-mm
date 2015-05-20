Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id E78986B0118
	for <linux-mm@kvack.org>; Wed, 20 May 2015 09:48:02 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so155641044wic.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 06:48:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gh11si2162288wjc.11.2015.05.20.06.48.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 May 2015 06:48:00 -0700 (PDT)
Message-ID: <1432129666.15239.22.camel@stgolabs.net>
Subject: Re: [PATCH 2/2] mm, memcg: Optionally disable memcg by default
 using Kconfig
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 20 May 2015 06:47:46 -0700
In-Reply-To: <1432126245-10908-3-git-send-email-mgorman@suse.de>
References: <1432126245-10908-1-git-send-email-mgorman@suse.de>
	 <1432126245-10908-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux-CGroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2015-05-20 at 13:50 +0100, Mel Gorman wrote:
> +config MEMCG_DEFAULT_ENABLED
> +	bool "Automatically enable memory resource controller"
> +	default y
> +	depends on MEMCG
> +	help
> +	  The memory controller has some overhead even if idle as resource
> +	  usage must be tracked in case a group is created and a process
> +	  migrated. As users may not be aware of this and the cgroup_disable=
> +	  option, this config option controls whether it is enabled by
> +	  default. It is assumed that someone that requires the controller
> +	  can find the cgroup_enable= switch.
> +
> +	  Say N if unsure. This is default Y to preserve oldconfig and
> +	  historical behaviour.

Out of curiosity, how do you expect distros to handle this? I mean, this
is a pretty general functionality and customers won't want to be
changing kernels (they may or may not use memcg). iow, will this ever be
disabled?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
