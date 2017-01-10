Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DDD1A6B0069
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 18:02:26 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y196so140364946ity.1
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 15:02:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a184si13685703itg.100.2017.01.10.15.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 15:02:26 -0800 (PST)
Subject: [LSF/MM TOPIC][LSF/MM,ATTEND] shared TLB, hugetln reservations
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <cad15568-221e-82b7-a387-f23567a0bc76@oracle.com>
Date: Tue, 10 Jan 2017 15:02:22 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

I would like to propose shared context/TLB support as a topic.  A RFC
of my initial efforts in this area can be seen at:

https://lkml.org/lkml/2016/12/16/508

That description (and proposed changes) are primarily Sparc specific.
However, there are some mm architecture independent issues to consider.
For example:
- How does user specify desire for shared context mapping?  mmap and
  shmat?  new flags?
- mmap and shmat (or other) hooks for architecture specific callouts.
- How to carry the desire for shared context mappings?  vm_area_struct
  and associated flag?
As noted, most of this is Sparc specific.  This may sound like a crazy
idea, but if PCID is not being used on x86 for individual address spaces
perhaps it could be used for shared context?  I haven't given it much
thought yet, but hate to see HW features going unused.

Another more concrete topic is hugetlb reservations.  Michal Hocko
proposed the topic "mm patches review bandwidth", and brought up the
related subject of areas in need of attention from an architectural
POV.  I suggested that hugetlb reservations was one such area.  I'm
guessing it was introduced to solve a rather concrete problem.  However,
over time additional hugetlb functionality was added and the
capabilities of the reservation code was stretched to accommodate.
It would be good to step back and take a look at the design of this
code to determine if a rewrite/redesign is necessary.  Michal suggested
documenting the current design/code as a first step.  If people think
this is worth discussion at the summit, I could put together such a
design before the gathering.

In addition to the proposing the above topics, I would  simply like
to attend the summit this year.  My main area of interest is anything
having to do with huge pages.  Even though it may seem like hugetlb
is dying, it is very much alive and is heavy use by some DB implementations.
hugetlb support is being added to userfaultfd that benefits qumu postcopy
as well having future DB uses.  In addition to traditional huge pages, I am
interested interested in DAX's handling of huge (non-base size) pages.
In general, almost any mm related topic is of interest to me.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
