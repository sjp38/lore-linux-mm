Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 968126B006C
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:02:10 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id hl2so6803837igb.0
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 15:02:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gb19si7782252icb.23.2014.12.15.15.02.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Dec 2014 15:02:09 -0800 (PST)
Received: from akpm3.mtv.corp.google.com (unknown [216.239.45.95])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 2CA37ACD
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 23:02:08 +0000 (UTC)
Date: Mon, 15 Dec 2014 15:02:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Stalled MM patches for review
Message-Id: <20141215150207.67c9a25583c04202d9f4508e@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


I'm sitting on a bunch of patches which have question marks over them. 
I'll send them out now.  Can people please dig in and see if we can get
them finished off one way or the other?

My notes (which may be out of date):

mm-page_isolation-check-pfn-validity-before-access.patch:
  - Might be unneeded. mhocko has issues.

mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask.patch:
  - Needs review and checking

mm-page_alloc-embed-oom-killing-naturally-into-allocation-slowpath.patch:
  - mhocko wanted a changelog update

mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone.patch:
  - Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> has issues with it

mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch:
  - Adds a comment whcih might not be true?

fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch:
  - Unsure whether or not this helps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
