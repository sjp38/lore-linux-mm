Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j324KwkN007986
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:58 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j324KwZo087102
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:58 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j324KwLf018175
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:58 -0500
Date: Fri, 1 Apr 2005 19:10:20 -0800
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: [PATCH 0/6] CKRM: Memory controller for CKRM
Message-ID: <20050402031020.GA23284@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello ckrm-tech members,

Here is the latest CKRM Memory controller patch against the patchset Gerrit
released couple of days back.

I applied the feedback I got on/off the list.

It is tested on i386.

Hello linux-mm members,

These are set of patches that provides the control of memory under the CKRM
framework(Details at http://ckrm.sf.net). I eagerly wait for your
feedback/comments/suggestions/concerns etc.,

To All,

I am looking for improvement suggestions
        - to not have a field in the page data structure for the mem
          controller
	- to make vmscan.c cleaner.

--------
Patches are
11-01-mem_base_changes:
        Basic changes to the core kernel to support memory controller.

11-02-mem_base-core:
        To fit in the ckrm framework. No support for guarantee, limit in
this
        patch. No config file support also.

11-03-mem_core-limit:
        Support for limit is added.

11-04-mem_limit-guar:
        Support for guarantee is added.

11-05-mem_guar-config:
        Support for few config parameters added.

11-06-mem_config-docs:
        Ofcourse... Documentation.

regards,

chandra


-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
