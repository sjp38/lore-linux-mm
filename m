Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 94C0F6B013D
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 13:46:46 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 26 Mar 2013 13:46:45 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id D7B2D6E803F
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 13:46:35 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2QHkbpT216762
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 13:46:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2QHkbno003405
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 13:46:37 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 0/3] mm: avoid duplication of setup_nr_node_ids()
Date: Tue, 26 Mar 2013 10:45:59 -0700
Message-Id: <1364319962-30967-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

In arch/powerpc, arch/x86, and mm/page_alloc code to setup nr_node_ids based on
node_possible_map is duplicated.

This patchset switches those copies to calling the function provided by page_alloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
