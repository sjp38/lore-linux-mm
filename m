Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D052D6B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 10:11:53 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id l18so644279wgh.17
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 07:11:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b44si6066494eez.35.2014.01.08.07.11.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 07:11:52 -0800 (PST)
Date: Wed, 8 Jan 2014 16:11:51 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [LSF/MM ATTEND, TOPIC] memcg topics and user defined oom policies
Message-ID: <20140108151151.GA2720@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hi,
I would like to attend LSF/MM this year. I am mostly interested in the
MM track.

I would like to discuss memcg lowlimit reclaim as a replacement for soft
limit reclaim which should be deprecated and dropped eventually. The
patches have been sent without any feedback yet. We have discussed this
at the Kernel Summit in Edinburgh and had a general agreement on the
topic so I hope this will settle down before the conference already but
there might be some details to talk about in person.

There are some long term plans for memcg like dirty pages throttling
which haven't moved for quite some time (we almost have dirty page
tracking which is a good step forward but still a long way to go).
Another long term item is ~0% cost with memcg enabled but not in use
(aka no groups existing apart from the root).
There were some attempts to get rid of page_cgroup descriptors. We are
at 16B (64b) currently which is not bad but maybe we can do better.
Kamezawa was working on this but he was busy with other project last
year.
Overall simplification/cleanup of the code is also long due as well.

David was proposing memory reserves for memcg userspace OOM handlers.
I found the idea interesting at first but I am getting more and more
skeptical about fully supporting oom handling from within under-oom
group usecase. Google is using this setup and we should discuss what is
the best approach longterm because the same thing can be achieved by a
proper memcg hierarchy as well.

While we are at memcg OOM it seems that we cannot find an easy consensus
on when is the line when the userspace should be notified about OOM [1].

I would also like to continue discussing user defined OOM policies.
The last attempt to resurrect the discussion [2] ended up without any
strong conclusion but there seem to be some opposition against direct
handling of the global OOM from userspace as being too subtle and
dangerous. Also using memcg interface doesn't seem to be welcome warmly.
This leaves us with either loadable modules approach or a generic filter
mechanism which haven't been discussed that much. Or something else?
I hope we can move forward finally.

But I am interested in other mm related discussions as well.

---
[1] - https://lkml.org/lkml/2013/11/14/586
[2] - https://lkml.org/lkml/2013/11/19/191
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
