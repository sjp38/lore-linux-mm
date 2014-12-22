Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4226B0032
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 18:51:34 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id wp4so23359961obc.11
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 15:51:34 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id qt3si11444651oeb.63.2014.12.22.15.51.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 15:51:33 -0800 (PST)
Message-ID: <1419292284.8812.5.camel@stgolabs.net>
Subject: [LSF/MM ATTEND] mmap_sem and mm performance testing
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 22 Dec 2014 15:51:24 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hello,

I would like to attend LSF/MM 2015. While I am very much interested in
general mm performance topics, I would particularly like to discuss:

(1) Where we are at with the mmap_sem issues and progress. This topic
constantly comes up each year [1,2,3] without much changing. While the
issues are very clear (both long hold times, specially in fs paths and
coarse lock granularity) it would be good to detail exactly *where*
these problems are and what are some of the show stoppers. In addition,
present overall progress and benchmark numbers on fine graining via
range locking (I am currently working on this as a follow on to recent
i_mmap locking patches) and experimental work,
such as speculative page fault patches[4]. If nothing else, this session
can/should produce a list of tangible todo items.

(2) Expanding our mm performance testing. I am working on incorporating
multiple VM-intensive benchmarks taken from system research papers into
mmtests. Academics tend to choose their benchmarking material carefully
and there's no reason we cannot learn from that. The downside is that
their tools are painfully complex to use, and thus not very popular in
the kernel community. Two examples are popular suites such as mosbench
and PARSEC. The idea would be to present easy to use, higher level
benchmarks to expose in-memory scalability issues that be useful to
kernel hackers. Additionally, possibly discuss other tools folks use
that can be beneficial to our internal automation.

[1] http://lwn.net/Articles/490501/
[2] http://lwn.net/Articles/548098/
[3] http://lwn.net/Articles/591978/
[4] http://lwn.net/Articles/617344/

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
