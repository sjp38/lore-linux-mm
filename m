Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id D51AC6B0037
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 01:11:24 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id c6so7425971lan.10
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 22:11:24 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ya3si3953827lbb.86.2014.01.21.22.11.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 22:11:23 -0800 (PST)
Message-ID: <52DF6100.4060402@parallels.com>
Date: Wed, 22 Jan 2014 10:11:12 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: vmscan: shrink_slab: rename max_pass -> freeable
References: <4e2efebe688e06574f6495c634ac45d799e1518d.1389982079.git.vdavydov@parallels.com> <alpine.DEB.2.02.1401211420460.1666@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1401211420460.1666@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

On 01/22/2014 02:22 AM, David Rientjes wrote:
> On Fri, 17 Jan 2014, Vladimir Davydov wrote:
>
>> The name `max_pass' is misleading, because this variable actually keeps
>> the estimate number of freeable objects, not the maximal number of
>> objects we can scan in this pass, which can be twice that. Rename it to
>> reflect its actual meaning.
>>
>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Dave Chinner <dchinner@redhat.com>
>> Cc: Glauber Costa <glommer@gmail.com>
> This doesn't compile on linux-next:
>
> mm/vmscan.c: In function a??shrink_slab_nodea??:
> mm/vmscan.c:300:23: error: a??max_passa?? undeclared (first use in this function)
> mm/vmscan.c:300:23: note: each undeclared identifier is reported only once for each function it appears in
>
> because of b01fa2357bca ("mm: vmscan: shrink all slab objects if tight on 
> memory") from an author with a name remarkably similar to yours.

Oh, sorry. I thought it hadn't been committed there yet.

> Could you rebase this series on top of your previous work that is already in -mm?

Sure.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
