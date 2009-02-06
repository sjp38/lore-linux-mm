Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D19DA6B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 03:45:45 -0500 (EST)
Date: Fri, 6 Feb 2009 00:45:44 -0800 (PST)
From: Vira <sri1369_s@yahoo.com>
Reply-To: sri1369_s@yahoo.com
Subject: Mapping non-page aligned address
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Message-ID: <425139.79199.qm@web33407.mail.mud.yahoo.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hey all,

Is there a way to map a non-page aligned kernel physical address to user virtual address? remap_pfn_range and vm_insert_page operate only on page-aligned physical addresses.

If there is no such support, would it be too complicated to try out writing something on my own to map non-page aligned addresses (the data size is under my control - so I can make that a multiple of page size)?

Any suggestions appreciated.

Thanks,
-- vira


      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
