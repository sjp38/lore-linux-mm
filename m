Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 53E876B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 13:44:34 -0400 (EDT)
Received: by wibhq7 with SMTP id hq7so897833wib.8
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 10:44:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50633D24.6020002@parallels.com>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com>
	<1347977050-29476-5-git-send-email-glommer@parallels.com>
	<20120926140347.GD15801@dhcp22.suse.cz>
	<20120926163648.GO16296@google.com>
	<50633D24.6020002@parallels.com>
Date: Wed, 26 Sep 2012 10:44:32 -0700
Message-ID: <CAOS58YNj-L4ocwn-c27ho4WPW41MKOeJbnLZ8N8r4eUkoxC7GA@mail.gmail.com>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Glauber.

On Wed, Sep 26, 2012 at 10:36 AM, Glauber Costa <glommer@parallels.com> wrote:
> This was discussed multiple times. Our interest is to preserve existing
> deployed setup, that were tuned in a world where kmem didn't exist.
> Because we also feed kmem to the user counter, this may very well
> disrupt their setup.

So, that can be served by .kmem_accounted at root, no?

> User memory, unlike kernel memory, may very well be totally in control
> of the userspace application, so it is not unreasonable to believe that
> extra pages appearing in a new kernel version may break them.
>
> It is actually a much worse compatibility problem than flipping
> hierarchy, in comparison

Again, what's wrong with one switch at the root?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
