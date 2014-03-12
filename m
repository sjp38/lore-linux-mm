Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id AC2696B0039
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 21:28:45 -0400 (EDT)
Received: by mail-bk0-f45.google.com with SMTP id na10so1387096bkb.32
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 18:28:45 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id qr10si9820715bkb.254.2014.03.11.18.28.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 18:28:44 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/8] memcg: charge path cleanups
Date: Tue, 11 Mar 2014 21:28:26 -0400
Message-Id: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andrew,

here are some cleanups and refactoring efforts of the memcg charge
path for 3.15 from Michal and me.

 mm/memcontrol.c | 319 +++++++++++++++++++-----------------------------------
 1 file changed, 112 insertions(+), 207 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
