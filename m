Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 654446B0108
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 12:33:33 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so7563704pbb.3
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 09:33:33 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bs8si7506092pad.94.2014.03.18.09.33.31
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 09:33:32 -0700 (PDT)
Message-ID: <5328753B.2050107@intel.com>
Date: Tue, 18 Mar 2014 09:32:59 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] Testing Large-Memory Hardware
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, lsf@lists.linux-foundation.org, Wu Fengguang <fengguang.wu@intel.com>

I have a quick topic that could perhaps be addressed along with the
testing topic that Dave Jones proposed.  I won't be attending, but there
will be a couple of other Intel folks there.  This should be a fairly
quick thing to address.

Topic:

Fengguang Wu who runs the wonderful LKP and 0day build tests was
recently asking if I thought there was value in adding a large-memory
system, say with 1TB of RAM.  LKP is the system that generates these
kinds of automated bug reports and performance tests:

	http://lkml.org/lkml/2014/3/9/201

My gut reaction was that we'd probably be better served by putting
resources in to systems with higher core counts rather than lots of RAM.
 I have encountered the occasional boot bug on my 1TB system, but it's
far from a frequent occurrence, and even more infrequent to encounter
things at runtime.

Would folks agree with that?  What kinds of tests, benchmarks, stress
tests, etc... do folks run that are both valuable and can only be run on
a system with a large amount of actual RAM?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
