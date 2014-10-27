Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 22F31900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 16:40:07 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id p9so6422833lbv.19
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 13:40:06 -0700 (PDT)
Received: from mail.ud10.udmedia.de (ud10.udmedia.de. [194.117.254.50])
        by mx.google.com with ESMTPS id j9si21754399lab.13.2014.10.27.13.40.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Oct 2014 13:40:05 -0700 (PDT)
Date: Mon, 27 Oct 2014 21:40:03 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: isolate_freepages_block(): very high intermittent overhead
Message-ID: <20141027204003.GB348@x4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>

On my v3.18-rc2 kernel isolate_freepages_block() sometimes shows up very
high (>20%) in perf top during the configuration phase of software
builds. It increases build time considerably.

Unfortunately the issue is not 100% reproducible, because it appears
only intermittently. And the symptoms vanish after a few minutes.

I think the "mm, compaction" series from Vlastimil is to blame, but it's
hard to be sure when bisection doesn't work.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
