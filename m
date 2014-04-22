Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 34A4B6B0062
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:03:23 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so4972719eek.3
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 11:03:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y6si60831776eep.107.2014.04.22.11.03.20
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 11:03:21 -0700 (PDT)
Date: Tue, 22 Apr 2014 14:03:08 -0400
From: Dave Jones <davej@redhat.com>
Subject: 3.15rc2 hanging processes on exit.
Message-ID: <20140422180308.GA19038@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

I've got a test box that's running my fuzzer that is in an odd state.
The processes are about to end, but they don't seem to be making any
progress.  They've been spinning in the same state for a few hours now..

perf top -a is showing a lot of time is being spent in page_fault and bad_gs

there's a large trace file here from the function tracer:
http://codemonkey.org.uk/junk/trace.out

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
