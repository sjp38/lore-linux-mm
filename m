Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 424446B038B
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 23:12:59 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d185so274057140pgc.2
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 20:12:59 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id b21si27404pgg.194.2017.02.21.20.12.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 20:12:58 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 5so21632000pgj.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 20:12:58 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 22 Feb 2017 15:12:50 +1100
Subject: Re: [PATCH] mm: memcontrol: provide shmem statistics
Message-ID: <20170222041250.GA9967@balbir.ozlabs.ibm.com>
References: <20170221164343.32252-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170221164343.32252-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Chris Down <cdown@fb.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Feb 21, 2017 at 11:43:43AM -0500, Johannes Weiner wrote:
> Cgroups currently don't report how much shmem they use, which can be
> useful data to have, in particular since shmem is included in the
> cache/file item while being reclaimed like anonymous memory.
> 
> Add a counter to track shmem pages during charging and uncharging.
> 
> Reported-by: Chris Down <cdown@fb.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---

Makes sense

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
