Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 718E4828DF
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 01:37:50 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id n128so53549835pfn.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 22:37:50 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id ca7si15029085pad.240.2016.01.22.22.37.49
        for <linux-mm@kvack.org>;
        Fri, 22 Jan 2016 22:37:49 -0800 (PST)
Message-ID: <1453531056.15363.1.camel@kernel.org>
Subject: [LSF/MM ATTEND] Persistent Memory Error Handling
From: Vishal Verma <vishal@kernel.org>
Date: Fri, 22 Jan 2016 23:37:36 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

Hi,

I'd like to attend LSF/MM. My primary topic of interest is the above as
proposed by Jeff Moyer:

http://www.spinics.net/lists/linux-mm/msg100560.html

I wrote the initial enabling for error handling that was merged for 4.5
(Building a poison list in the libnvdimm subsystem, exposing it as
'badblocks'), and am working on subsequent improvements in this areaa.
These would include making the initial poison gathering asynchronous,
and finer grained DAX control instead of turningA DAX off entirely in
the presence of poison which we currently do.

Another topic of discussion I'd like to propose within this session is
to explore if there are use cases that the now-generic badblocks
implementation can fit. There is at least one opportunity of
consolidation between md-raid's sysfs representation of badblocks, and
the generically available one in gendisk.

Thanks,
	-Vishal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
