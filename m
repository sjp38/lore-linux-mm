Received: from cacc-3.uni-koblenz.de (cacc-3.uni-koblenz.de [141.26.131.3])
	by mailhost.uni-koblenz.de (8.9.3/8.9.3) with ESMTP id MAA29851
	for <linux-mm@kvack.org>; Fri, 19 May 2000 12:01:40 +0200 (MET DST)
Date: Fri, 19 May 2000 11:16:42 +0200
From: Ralf Baechle <ralf@uni-koblenz.de>
Subject: Kernel RSS statistics
Message-ID: <20000519111642.D702@uni-koblenz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mm/memory.c, function zap_page_range has the following code in it:

        /*
         * Update rss for the mm_struct (not necessarily current->mm)
         */
        if (mm->rss > 0) {
                mm->rss -= freed;
                if (mm->rss < 0)
                        mm->rss = 0;
        }

But mm->rss is an unsigned long, so the condition mm->rss < 0 cannot
ever get true.  Anyway, assuming it'd be signed I don't see how it
should ever get zero unless the RSS statistics is broken?

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
