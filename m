Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E81D96B02F5
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 06:02:25 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so41736506pdr.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 03:02:25 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id jc8si12108638pbd.251.2015.07.16.03.02.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 03:02:24 -0700 (PDT)
Date: Thu, 16 Jul 2015 13:02:11 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v8 0/7] idle memory tracking
Message-ID: <20150716100211.GC2001@esperanza>
References: <cover.1436967694.git.vdavydov@parallels.com>
 <CAJu=L59MjY4F4G2bZh+hrt7aqw3R9mWPeYK65smQWUvMhz85aA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAJu=L59MjY4F4G2bZh+hrt7aqw3R9mWPeYK65smQWUvMhz85aA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 15, 2015 at 01:47:15PM -0700, Andres Lagar-Cavilla wrote:
> I think the remaining question here is performance.
> 
> Have you conducted any studies where
> - there is a workload
> - a daemon is poking kpageidle every N seconds/minutes
> - what is the daemon cpu consumption?
> - what is the workload degradation if any?
> 
> N candidates include 30 seconds, 1 minute, 2 minutes, 5 minutes....
> 
> Workload candidates include TPC, spec int memory intensive things like
> 429.mcf, stream (http://www.cs.virginia.edu/stream/ "sustainable
> memory bandwidth" vs floating point performance)
> 
> I'm not asking for a research paper, but if, say, a 2 minute-period
> daemon introduces no degradation and adds up to a minute of cpu per
> hour, then we're golden.

Fair enough. Will do that soon and report back.

Thanks a lot for the review, it was really helpful!

Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
