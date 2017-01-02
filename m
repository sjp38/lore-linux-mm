Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07DF86B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 10:31:08 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so76225394wmu.1
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 07:31:07 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id g23si40448576wme.37.2017.01.02.07.31.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jan 2017 07:31:06 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id hb5so35690455wjc.2
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 07:31:06 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] numa node stats alternative fix
Date: Mon,  2 Jan 2017 16:30:55 +0100
Message-Id: <20170102153057.9451-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Jia He <hejianet@gmail.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this is an alternative fix for [1] which is currently sitting in the mm
tree.  I believe that the patch 1 is better because it allows to get rid
of __GFP_OTHER_NODE (patch 2) and it uses less branches as well. Vlastimil
has also shown [2] that the patch from Jia He is not fully compatible with
the code before the patch it tries to fix. I do not think that the issue
is serious enough to warrant stable tree inclusion.

Can we have these patches merged instead?

[1] http://lkml.kernel.org/r/1481522347-20393-1-git-send-email-hejianet@gmail.com
[2] http://lkml.kernel.org/r/233ed490-afb9-4644-6d84-c9f888882da2@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
