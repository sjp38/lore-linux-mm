Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A12666B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 19:23:07 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 194so145129428pgd.7
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 16:23:07 -0800 (PST)
Received: from osg.samsung.com (ec2-52-27-115-49.us-west-2.compute.amazonaws.com. [52.27.115.49])
        by mx.google.com with ESMTP id h82si20962259pfj.218.2017.01.17.16.23.06
        for <linux-mm@kvack.org>;
        Tue, 17 Jan 2017 16:23:06 -0800 (PST)
From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Linux 4.10-rc2 arm: dmesg flooded with alloc_contig_range: [X, Y)
 PFNs busy
Message-ID: <6c67577e-8b72-c958-40af-2096d8840fbe@osg.samsung.com>
Date: Tue, 17 Jan 2017 17:23:03 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com
Cc: LKML <linux-kernel@vger.kernel.org>, Shuah Khan <shuahkh@osg.samsung.com>, linux-mm@kvack.org

Hi,

dmesg floods with PFNs busy messages.

[10119.071455] alloc_contig_range: [bb900, bbc00) PFNs busy
[10119.071631] alloc_contig_range: [bba00, bbd00) PFNs busy
[10119.071762] alloc_contig_range: [bbb00, bbe00) PFNs busy
[10119.071940] alloc_contig_range: [bbc00, bbf00) PFNs busy
[10119.072039] alloc_contig_range: [bbd00, bc000) PFNs busy
[10119.072188] alloc_contig_range: [bbe00, bc100) PFNs busy
[10119.072301] alloc_contig_range: [bbf00, bc200) PFNs busy
[10119.072403] alloc_contig_range: [bc000, bc300) PFNs busy
[10119.072549] alloc_contig_range: [bc100, bc400) PFNs busy
[10119.072584] [drm:exynos_drm_gem_create] *ERROR* failed to allocate buffer.

I think this is triggered when drm tries to allocate CMA buffers.
I might have seen one or two messages in 4.9, but since 4.10, it
just floods dmesg.

Is this a known problem? I am seeing this on odroid-xu4

Linux odroid 4.10.0-rc2-00251-ge03c755-dirty #12 SMP PREEMPT
Wed Jan 11 23:12:52 UTC 2017 armv7l armv7l armv7l GNU/Linux

thanks,
-- Shuah

-- 
Shuah Khan
Sr. Linux Kernel Developer
Open Source Innovation Group
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
