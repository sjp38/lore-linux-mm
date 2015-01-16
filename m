Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9AE6B0038
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:38:13 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id x12so15642474qac.11
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 06:38:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j18si6122937qae.88.2015.01.16.06.38.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 06:38:12 -0800 (PST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH 0/2] Tiny adjustments to /proc/pid/numa_maps interface and documentation
Date: Fri, 16 Jan 2015 08:50:49 -0500
Message-Id: <cover.1421415776.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, jweiner@redhat.com, dave.hansen@linux.intel.com, rientjes@google.com, linux-mm@kvack.org

This small patchset aims to add missing documentation to the /proc/pid/numa_maps interface
as well as perform a small adjustment on the report output, as suggested by
Andrew Morton, in the following discussion thread:
 * https://lkml.org/lkml/2015/1/5/769 

Rafael Aquini (2):
  documentation: proc: add /proc/pid/numa_maps interface explanation
    snippet
  fs: proc: task_mmu: bump kernelpagesize_kB to EOL in
    /proc/pid/numa_maps

 Documentation/filesystems/proc.txt | 33 +++++++++++++++++++++++++++++++++
 fs/proc/task_mmu.c                 |  4 ++--
 2 files changed, 35 insertions(+), 2 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
