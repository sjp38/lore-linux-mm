Received: from parora (parora [192.168.8.140])
	by mailhost.baypackets.com (8.9.3+Sun/8.9.3) with ESMTP id PAA13216
	for <linux-mm@kvack.org>; Wed, 26 May 2004 15:07:28 +0530 (IST)
From: "Pankaj" <pankaj.arora@baypackets.com>
Subject: Memory problem
Date: Wed, 26 May 2004 15:44:17 +0530
Message-ID: <NIBBLBNEDKOCMIIGKJCHMEJICAAA.pankaj.arora@baypackets.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I doing some performance test on my application. Platform is

Red Hat Enterprise Linux ES release 3 (Taroon)
Kernel 2.4.21-4.ELsmp on an i686

I have done some load test for my application and afterwards closed my
application. Now
no application is running on my machine. Following is output of my
/proc/meminfo

[root@bplinux89 rsinsp]# cat /proc/meminfo
        total:    used:    free:  shared: buffers:  cached:
Mem:  4224958464 2294509568 1930448896        0 200970240 1705332736
Swap: 2146787328        0 2146787328
MemTotal:      4125936 kB
MemFree:       1885204 kB
MemShared:           0 kB
Buffers:        196260 kB
Cached:        1665364 kB
SwapCached:          0 kB
Active:         473520 kB
ActiveAnon:      40996 kB
ActiveCache:    432524 kB
Inact_dirty:    118716 kB
Inact_laundry: 1222752 kB
Inact_clean:     86976 kB
Inact_target:   380392 kB
HighTotal:     3276716 kB
HighFree:      1689640 kB
LowTotal:       849220 kB
LowFree:        195564 kB
SwapTotal:     2096472 kB
SwapFree:      2096472 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     2048 kB


I am really worried about high Inact_laundry and cached memory size. Is it
normal?

Regards,
Pankaj.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
