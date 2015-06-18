Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 80DD36B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:57:37 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so17508878wiw.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 02:57:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cx6si35407934wib.71.2015.06.18.02.57.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Jun 2015 02:57:36 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 0/2] oom: sysrq+f shouldn't not panic the system + cleanup
Date: Thu, 18 Jun 2015 11:57:25 +0200
Message-Id: <1434621447-21175-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
I have split the patch sent previously http://marc.info/?l=linux-mm&m=143323521519798&w=2
into two parts. The first patch prevents from the panic when OOM
killer is sysrq triggered. This is an obvious bug fix and hopefuly not
controversial.

I still believe that combining the regular and the sysrq triggered OOM
paths is ugly, error prone and it deserves a split up which is done in
the second patch. There are no functional changes introduced there.
I have dropped __oom_kill_process part because this one turned out
to be harmless for for the sysrq+f path - I couldn't have found any
interruptible sleep after exit_signals.
I find the resulting code easier to follow (35 (+), 22 (-) sounds like a
reasonable code overhead for that purpose).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
