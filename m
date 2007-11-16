Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id lAG4Pj7m011508
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 20:25:45 -0800
Received: from [172.18.116.11] (freakapc.corp.google.com [172.18.116.11])
	by zps37.corp.google.com with ESMTP id lAG4PjRV026573
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 20:25:45 -0800
Message-ID: <473D1BC9.8050904@google.com>
Date: Thu, 15 Nov 2007 20:25:45 -0800
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: page_referenced() and VM_LOCKED
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

page_referenced_file() checks for the vma to be VM_LOCKED|VM_MAYSHARE
and adds returns 1. We don't do the same in page_referenced_anon(). I
would've thought the point was to treat locked pages as active, never
pushing them into the inactive list, but since that's not quite what's
happening I was hoping someone could give me a clue.

	Thanks,
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
