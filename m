Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 08A556B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 01:35:01 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id um1so2732469pbc.5
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 22:35:01 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2402:b800:7003:1:1::1])
        by mx.google.com with ESMTPS id sj5si5171652pab.197.2014.01.29.22.35.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jan 2014 22:35:00 -0800 (PST)
Date: Thu, 30 Jan 2014 17:34:57 +1100
From: Anton Blanchard <anton@samba.org>
Subject: /proc/pid/numa_maps no longer shows "default" policy
Message-ID: <20140130173457.115a30f8@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: linux-mm@kvack.org


Hi Mel,

We recently noticed that /proc/pid/numa_maps used to show default
policy mappings as such:

cat /proc/self/numa_maps 
00100000 default mapped=1 mapmax=339 active=0 N0=1

But now it shows them as prefer:X:

cat /proc/self/numa_maps
10000000 prefer:1 file=/usr/bin/cat mapped=1 N0=1

It looks like this was caused by 5606e387 (mm: numa: Migrate on
reference policy). I'm not sure if this is expected, but we don't have
CONFIG_NUMA_BALANCING enabled on ppc64 so I wasn't expecting processes
to have a particular node affinity by default.

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
