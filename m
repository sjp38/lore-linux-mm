Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id E0AC66B0035
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 04:07:02 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id e4so3228857wiv.4
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 01:07:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ez4si13719366wjd.25.2014.02.18.01.07.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 01:07:01 -0800 (PST)
Date: Tue, 18 Feb 2014 10:06:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: ppc: RECLAIM_DISTANCE 10?
Message-ID: <20140218090658.GA28130@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
I have just noticed that ppc has RECLAIM_DISTANCE reduced to 10 set by
56608209d34b (powerpc/numa: Set a smaller value for RECLAIM_DISTANCE to
enable zone reclaim). The commit message suggests that the zone reclaim
is desirable for all NUMA configurations.

History has shown that the zone reclaim is more often harmful than
helpful and leads to performance problems. The default RECLAIM_DISTANCE
for generic case has been increased from 20 to 30 around 3.0
(32e45ff43eaf mm: increase RECLAIM_DISTANCE to 30).

I strongly suspect that the patch is incorrect and it should be
reverted. Before I will send a revert I would like to understand what
led to the patch in the first place. I do not see why would PPC use only
LOCAL_DISTANCE and REMOTE_DISTANCE distances and in fact machines I have
seen use different values.

Anton, could you comment please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
