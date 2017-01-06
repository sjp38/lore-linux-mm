Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB4ED6B0275
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 17:29:13 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id n204so88906052oif.6
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 14:29:13 -0800 (PST)
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com. [15.241.140.73])
        by mx.google.com with ESMTPS id h8si1319082otg.80.2017.01.06.14.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 14:29:13 -0800 (PST)
Date: Fri, 6 Jan 2017 14:29:12 -0800
From: Till Smejkal <till.smejkal@hpe.com>
Subject: Benchmarks for the Linux kernel MM architecture
Message-ID: <20170106222912.o6vkh7rarxdak4ga@arch-test>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Till Smejkal <till.smejkal@hpe.com>

Dear Linux MM community

My name is Till Smejkal and I am a PhD Student at Hewlett Packard Enterprise. For a
couple of weeks I have been working on a patchset for the Linux kernel which
introduces a new functionality that allows address spaces to be first class citizens
in the OS. The implementation is based on a concept presented in this [1] paper.

The basic idea of the patchset is that an AS not necessarily needs to be coupled with
a process but can be created and destroyed independently. A process still has its own
AS which is created with the process and which also gets destroyed with the process,
but in addition there can be other AS in the OS which are not bound to the lifetime
of any process. These additional AS have to be created and destroyed actively by the
user and can be attached to a process as additional AS. Attaching such an AS to a
process allows the process to have different views on the memory between which the
process can switch arbitrarily during its executing.

This feature can be used in various different ways. For example to compartmentalize a
process for security reasons or to improve the performance of data-centric
applications.

However, before I intend to submit the patchset to LKML, I first like to perform
some benchmarks to identify possible performance drawbacks introduced by my changes
to the original memory management architecture. Hence, I would like to ask if anyone
of you could point me to some benchmarks which I can run to test my patchset and
compare it against the original implementation.

If there are any questions, please feel free to ask me. I am happy to answer any
question related to the patchset and its idea/intention.

Regards
Till

P.S.: Please keep me in the CC since I am not subscribed to this mailing list.

[1] http://impact.crhc.illinois.edu/shared/Papers/ASPLOS16-SpaceJMP.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
