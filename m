Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f208.google.com (mail-pd0-f208.google.com [209.85.192.208])
	by kanga.kvack.org (Postfix) with ESMTP id 64EDF6B003B
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 10:06:45 -0400 (EDT)
Received: by mail-pd0-f208.google.com with SMTP id y10so73602pdj.11
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 07:06:45 -0700 (PDT)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id hj4si398836pac.39.2013.10.30.14.58.15
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 14:58:15 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/3 resend] memcg fixes for 3.12
Date: Wed, 30 Oct 2013 17:55:24 -0400
Message-Id: <1383170127-32284-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,

here are 3 more fixes that should go into 3.12.

#2 is a special case.  The locking scheme is not new and
it's late in the cycle, but the context of this lock was
heavily changed after the OOM rewrite this merge window,
it would be good to have lockdep coverage in the release.

Thanks!

 mm/memcontrol.c | 54 +++++++++++++++++++++++++-----------------------------
 1 file changed, 25 insertions(+), 29 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
