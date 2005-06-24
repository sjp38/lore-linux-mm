Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5OMInqo185512
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 18:18:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5OMImcC195008
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 16:18:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5OMIm4J028191
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 16:18:48 -0600
Subject: [PATCH 0/6] CKRM: Memory controller for CKRM
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
Content-Type: text/plain
Date: Fri, 24 Jun 2005 15:18:47 -0700
Message-Id: <1119651527.5105.11.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech <ckrm-tech@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello ckrm-tech members,

Here is the latest CKRM Memory controller patch against the patchset
Gerrit released on 06/22/05.

Changes made since last release of memory controller:
	- added in_interrupt() check in __alloc_pages
	- check pud while migrating pages
	- some typographical errors fixed.
	- Added a todo file to keep track of it in open.

It is tested on i386.

Currently disabled on NUMA.

Hello linux-mm members,

These are set of patches that provides the control of memory under the
CKRM
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
	this patch. No config file support also.

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
