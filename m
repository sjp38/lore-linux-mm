Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1DC6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 06:12:10 -0400 (EDT)
Received: by lbnq5 with SMTP id q5so20918471lbn.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 03:12:09 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com. [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id dd11si668739lac.21.2015.03.19.03.12.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 03:12:08 -0700 (PDT)
Received: by labjg1 with SMTP id jg1so57934711lab.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 03:12:07 -0700 (PDT)
Date: Thu, 19 Mar 2015 13:12:05 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 3/3] mm: idle memory tracking
Message-ID: <20150319101205.GC27066@moon>
References: <cover.1426706637.git.vdavydov@parallels.com>
 <0b70e70137aa5232cce44a69c0b5e320f2745f7d.1426706637.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b70e70137aa5232cce44a69c0b5e320f2745f7d.1426706637.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 18, 2015 at 11:44:36PM +0300, Vladimir Davydov wrote:
> Knowing the portion of memory that is not used by a certain application
> or memory cgroup (idle memory) can be useful for partitioning the system
> efficiently. Currently, the only means to estimate the amount of idle
> memory provided by the kernel is /proc/PID/clear_refs. However, it has
> two serious shortcomings:
> 
>  - it does not count unmapped file pages
>  - it affects the reclaimer logic
> 
> This patch attempts to provide the userspace with the means to track
> idle memory without the above mentioned limitations.
...
> +static void set_mem_idle(void)
> +{
> +	int nid;
> +
> +	for_each_online_node(nid)
> +		set_mem_idle_node(nid);
> +}

Vladimir, might we need get_online_mems/put_online_mems here,
or if node gets offline this wont be a problem? (Asking
because i don't know).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
