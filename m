Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f174.google.com (mail-gg0-f174.google.com [209.85.161.174])
	by kanga.kvack.org (Postfix) with ESMTP id 901D26B00A2
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 17:22:26 -0500 (EST)
Received: by mail-gg0-f174.google.com with SMTP id g10so2801057gga.33
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:22:26 -0800 (PST)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id v3si7775594yhv.44.2014.01.21.14.22.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 14:22:24 -0800 (PST)
Received: by mail-yk0-f169.google.com with SMTP id q9so6651791ykb.0
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:22:24 -0800 (PST)
Date: Tue, 21 Jan 2014 14:22:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm: vmscan: shrink_slab: rename max_pass ->
 freeable
In-Reply-To: <4e2efebe688e06574f6495c634ac45d799e1518d.1389982079.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.02.1401211420460.1666@chino.kir.corp.google.com>
References: <4e2efebe688e06574f6495c634ac45d799e1518d.1389982079.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1552005430-1390342917=:1666"
Content-ID: <alpine.DEB.2.02.1401211422020.1666@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1552005430-1390342917=:1666
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.02.1401211422021.1666@chino.kir.corp.google.com>

On Fri, 17 Jan 2014, Vladimir Davydov wrote:

> The name `max_pass' is misleading, because this variable actually keeps
> the estimate number of freeable objects, not the maximal number of
> objects we can scan in this pass, which can be twice that. Rename it to
> reflect its actual meaning.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Glauber Costa <glommer@gmail.com>

This doesn't compile on linux-next:

mm/vmscan.c: In function a??shrink_slab_nodea??:
mm/vmscan.c:300:23: error: a??max_passa?? undeclared (first use in this function)
mm/vmscan.c:300:23: note: each undeclared identifier is reported only once for each function it appears in

because of b01fa2357bca ("mm: vmscan: shrink all slab objects if tight on 
memory") from an author with a name remarkably similar to yours.  Could 
you rebase this series on top of your previous work that is already in 
-mm?
--531381512-1552005430-1390342917=:1666--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
