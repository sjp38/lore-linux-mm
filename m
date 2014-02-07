Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id 787616B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:04:31 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so1719710ead.36
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:04:30 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id g47si9331467eet.213.2014.02.07.09.04.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 09:04:29 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/8] memcg: charge path cleanups
Date: Fri,  7 Feb 2014 12:04:17 -0500
Message-Id: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Michal,

I took some of your patches and combined them with the charge path
cleanups I already had and the changes I made after our discussion.

I'm really happy about where this is going:

 mm/memcontrol.c | 298 ++++++++++++++++--------------------------------------
 1 file changed, 87 insertions(+), 211 deletions(-)

let me know what you think!

Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
