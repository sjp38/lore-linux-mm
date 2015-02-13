Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id EF21A6B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 19:59:02 -0500 (EST)
Received: by iecrp18 with SMTP id rp18so837315iec.9
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 16:59:02 -0800 (PST)
Received: from nm44-vm7.bullet.mail.ne1.yahoo.com (nm44-vm7.bullet.mail.ne1.yahoo.com. [98.138.120.247])
        by mx.google.com with ESMTPS id rs7si2558646igb.46.2015.02.12.16.58.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 16:59:02 -0800 (PST)
Date: Fri, 13 Feb 2015 00:52:56 +0000 (UTC)
From: Cheng Rk <crquan@ymail.com>
Reply-To: Cheng Rk <crquan@ymail.com>
Message-ID: <1918343840.1970155.1423788776414.JavaMail.yahoo@mail.yahoo.com>
Subject: How to controll Buffers to be dilligently reclaimed?
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>



Hi,

I have a system that application is doing a loop on top of block device,
(which I think is stupid,)
as more and more memory goes into Buffers, then applications started
to get -ENOMEM or be oom-killed later (depends on vm.overcommit_memory setting)


In this case, if I do a manual reclaim (echo 3 > /proc/sys/vm/drop_caches)
I see 90+% of the Buffers is reclaimable, but why it's not reclaimed
to fullfill applications' memory allocation request?



-bash-4.2$ sudo losetup -a
/dev/loop0: [0005]:16512 (/dev/dm-2)
-bash-4.2$ free -m
                     total          used         free      shared       buffers     cached
Mem:             48094        46081         2012              40           40324   2085
-/+ buffers/cache:             3671        44422
Swap:             8191                5         8186


I've tried sysctl mm.vfs_cache_pressure=10000 but that seems working to Cached
memory, I wonder is there another sysctl for reclaming Buffers?


Thanks,

- Derek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
