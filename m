Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 273B86B0031
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 10:15:54 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1217084pdj.22
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:15:53 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so1355954pab.38
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:15:50 -0700 (PDT)
Message-Id: <20130926141428.392345308@kernel.org>
Date: Thu, 26 Sep 2013 22:14:28 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [RFC 0/4] cleancache: SSD backed cleancache backend
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, dan.magenheimer@oracle.com

Hi,

This is a cleancache backend which caches page to disk, usually a SSD. The
usage model is similar like Windows readyboost. Eg, user plugs a USB drive,
and we use the USB drive to cache clean pages to reduce IO to hard disks.

So far I only did some micro benchmark, for example, access files with size
excess memory size. The result is positive. Of course we need solid data for
more real workloads. I'd like some comments/suggestions before I put more time
on it.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
