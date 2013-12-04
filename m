Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id CD5466B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 17:45:26 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so6959359bkz.1
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 14:45:26 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id f2si23505405bko.208.2013.12.04.14.45.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 14:45:25 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/2] mm: memcg: 3.13 fixes
Date: Wed,  4 Dec 2013 17:45:12 -0500
Message-Id: <1386197114-5317-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

here are two memcg fixes for 3.13.

The race condition in #1 is really long standing AFAICS, I just tagged
stable and will backport and evaluate this for any tree that sends me
a notice.

#2 changes what happens during a charge attempt between a task
entering memcg OOM and actually executing the kill.  I had these
charges bypass the limit in the hope that this would expedite the
kill, but there is no real evidence for it and David was worried about
an unecessary breach of isolation.  This was introduced in 3.12.

 mm/memcontrol.c | 38 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 37 insertions(+), 1 deletion(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
