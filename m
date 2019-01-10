Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBA248E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 04:57:55 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b7so4170354eda.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 01:57:55 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hh8-v6si2588570ejb.41.2019.01.10.01.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 01:57:54 -0800 (PST)
Date: Thu, 10 Jan 2019 10:57:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
Message-ID: <20190110095752.GK31793@dhcp22.suse.cz>
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
 <20190109141113.GW31793@dhcp22.suse.cz>
 <e9b64635-87cf-f330-acea-0ca681a2528e@virtuozzo.com>
 <20190109171021.GY31793@dhcp22.suse.cz>
 <3d4f4c83-44c9-c6d5-8dbe-c42a47e6c2bd@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3d4f4c83-44c9-c6d5-8dbe-c42a47e6c2bd@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, josef@toxicpanda.com, jack@suse.cz, hughd@google.com, darrick.wong@oracle.com, aryabinin@virtuozzo.com, guro@fb.com, mgorman@techsingularity.net, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 10-01-19 12:42:02, Kirill Tkhai wrote:
[...]
> In general, I think a some time useful design is not a Bible, that nobody
> is allowed to change. We should not limit us in something, in case of this
> has a sense and may be useful. This is just a note in general.

But any semantic exported to the userspace and real application
depending on it is carved in stone for ever. And this is the case here I
am afraid. So if we really need some sort of soft unmapping or
reparenting a memory from a memcg then we really need to find a
different way. I do not see a straightforward way right now TBH.
-- 
Michal Hocko
SUSE Labs
