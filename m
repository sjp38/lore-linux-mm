Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A88FB6B713A
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 18:16:30 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id b26so18982258qtq.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 15:16:30 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e1si1744867qki.190.2018.12.04.15.16.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 15:16:29 -0800 (PST)
Date: Tue, 4 Dec 2018 15:16:24 -0800
From: Larry Bassel <larry.bassel@oracle.com>
Subject: RFC: revisiting shared page tables
Message-ID: <20181204231623.GA19227@ubuette>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

In August 2005, Dave McCracken sent out a patch which implemented shared
page tables (http://lkml.iu.edu/hypermail/linux/kernel/0508.3/1623.html)
based on 2.6.13.

He also wrote two OLS papers about the topic
(https://landley.net/kdocs/ols/2003/ols2003-pages-315-320.pdf
and https://www.landley.net/kdocs/ols/2006/ols2006v2-pages-125-130.pdf), the
second of which was published after his patch submission.

This patch was discussed for a few days. It was not accepted.

There were several comments about technical issues (about a typo,
some questions about locking, how to search the vmas, whether one must
iterate through all of the vmas) which no doubt could be fixed, and
in fact Dave indicated that he would eventually provide a revised patch
which fixed these problems. AFAICT this never occurred.

However, there were also questions about whether sharing page tables would
provide any significant benefit.

Specifically, there were concerns about whether the patch would
improve performance at all (Dave indicated a 3% improvement on some
"large benchmarks"), especially once another change (the test at
at the beginning of copy_page_range() which prevents page table copies
in some cases) was merged (d992895ba2, which has been in the kernel since
2.6.14).

It was also suggested that the use of randomize_vm_space
might also make shared page tables uninteresting, though that objection
appeared to be addressed.

Isn't Linux kernel archaeology fun :-)

13 years have elapsed. Given the many changes in the kernel since the original
patch submission, I'd appreciate your insight into the following questions:

* Is there (still?) a need for shared page tables (and if not, why not?).
* If one were to resume work on this, is there any reason why one shouldn't
start with Dave's 2.6.13 patch (plus fixes to the known bugs in it)
and forward port it to the tip, rather than starting from scratch?

Thanks.

Larry Bassel
