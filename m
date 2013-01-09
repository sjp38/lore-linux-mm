Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id BDFF96B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 03:05:26 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id bi5so870796pad.27
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 00:05:26 -0800 (PST)
Message-ID: <1357718721.6568.3.camel@kernel.cn.ibm.com>
Subject: fadvise doesn't work well.
From: Simon Jeons <simon.jeons@gmail.com>
Date: Wed, 09 Jan 2013 02:05:21 -0600
Content-Type: multipart/mixed; boundary="=-EahHfBXECsKMsFjnnEWe"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, riel@redhat.com, Johannes Weiner <hannes@cmpxchg.org>, mtk.manpages@gmail.com, Fengguang Wu <fengguang.wu@intel.com>


--=-EahHfBXECsKMsFjnnEWe
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

In attanchment.

--=-EahHfBXECsKMsFjnnEWe
Content-Disposition: attachment; filename="11"
Content-Type: text/plain; name="11"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

root@kernel:~/Documents/mm/tools/linux-ftools# dd if=../../../images/ubuntu-11.04-desktop-i386.iso of=/tmpfs
1403484+0 records in
1403484+0 records out
718583808 bytes (719 MB) copied, 19.5054 s, 36.8 MB/s
root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fincore -s ../../../images/ubuntu-11.04-desktop-i386.iso 
filename                                                                                       size        total_pages    min_cached page       cached_pages        cached_size        cached_perc
--------                                                                                       ----        -----------    ---------------       ------------        -----------        -----------
../../../images/ubuntu-11.04-desktop-i386.iso                                             718583808             175436                  0             175436          718585856             100.00
---
total cached size: 718585856
root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fadvise ../../../images/ubuntu-11.04-desktop-i386.iso DONTNEED 0,718585856
Going to fadvise ../../../images/ubuntu-11.04-desktop-i386.iso as mode DONTNEED
offset: 0
length: 718583808
Invalid mode DONTNEED
root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fincore -s ../../../images/ubuntu-11.04-desktop-i386.iso 
filename                                                                                       size        total_pages    min_cached page       cached_pages        cached_size        cached_perc
--------                                                                                       ----        -----------    ---------------       ------------        -----------        -----------
../../../images/ubuntu-11.04-desktop-i386.iso                                             718583808             175436                  0             175436          718585856             100.00
---
total cached size: 718585856


--=-EahHfBXECsKMsFjnnEWe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
