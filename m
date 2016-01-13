Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id F14176B0265
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 17:49:17 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id cy9so365548250pac.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 14:49:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t76si4757450pfi.226.2016.01.13.14.49.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 14:49:17 -0800 (PST)
Date: Wed, 13 Jan 2016 14:49:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] mm: memcontrol: cgroup2 memory statistics
Message-Id: <20160113144916.03f03766e201b6b04a8a47cc@linux-foundation.org>
In-Reply-To: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
References: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, 13 Jan 2016 17:01:07 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hi Andrew,
> 
> these patches add basic memory statistics so that new users of cgroup2
> have some inkling of what's going on, and are not just confronted with
> a single number of bytes used.
> 
> This is very short-notice, but also straight-forward. It would be cool
> to get this in along with the lifting of the cgroup2 devel flag.
> 
> Michal, Vladimir, what do you think? We'll also have to figure out how
> we're going to represent and break down the "kmem" consumers.
> 

It would be nice to see example output, and a description of why this
output was chosen: what was included, what was omitted, why it was
presented this way, what units were chosen for displaying the stats and
why.  Will the things which are being displayed still be relevant (or
even available) 10 years from now.  etcetera.

And the interface should be documented at some point.  Doing it now
will help with the review of the proposed interface.

Because this stuff is forever and we have to get it right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
