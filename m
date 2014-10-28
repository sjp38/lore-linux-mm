Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 55726900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 11:01:25 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id r10so872774pdi.3
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 08:01:25 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id al14si1580059pac.80.2014.10.28.08.01.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 08:01:24 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id fp1so844345pdb.23
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 08:01:24 -0700 (PDT)
Received: from [172.16.42.1] (p654785.hkidff01.ap.so-net.ne.jp. [121.101.71.133])
        by mx.google.com with ESMTPSA id nz1sm1936802pdb.11.2014.10.28.08.01.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 08:01:23 -0700 (PDT)
Message-ID: <544FAFC0.7060401@gmail.com>
Date: Wed, 29 Oct 2014 00:01:20 +0900
From: Makoto Harada <makotouu@gmail.com>
MIME-Version: 1.0
Subject: Request for comments/ideas to indentify the cause of TLB entry corruption
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Dear experts,

My name is Makoto Harada, working for the ARM based board development manufacturer.
Our product is using Single 800 MHz Cortex-A9 processor, and using Linux 3.4 
kernel is running on.

Now, we are working on unexpected boot hang issue, which happens once per 20-100 
boots.
Simply explaining, the issue is as followings.

1. Data abort or prefetch abort exception happens to handle a certain page fault.
2. In page fault handler, it tries to fix the cause of page fault, however do 
nothing because
      PTE has nothing wrong.(The page is valid, AP(access permission field) is 
correct).
3.  After returning back to the user process, an access to the page occurs.
4.  Since page fault handler does nothing on #2, the access causes page fault again.
      Thus system falls into the infinite page fault handling loop between 2-4, 
so boot process never completed.

5. The page fault loop can be exited by invalidating the TLB entry of the page 
(we implemented the special routine for debug purpose.)

According to the symptom above, we think that due to some unknown reason TLB 
entry is corrupted.
We want to identify the root cause which could cause TLB entry corruption.

Since I'm newbie for this memory management topic, I would like to hear the 
advice of experts.
How you guys approach this kind of issue ? Any comments are highly appreciated.

P.S We know that Linux 3.4 is a little bit old, however we have to keep using 
this version due to our private reason.

Kind Regards,
Makoto Harada

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
