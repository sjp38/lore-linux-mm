Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1753F6B025E
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 09:20:59 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id c79so44882889ybf.2
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 06:20:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l129si5898015ybc.276.2016.09.13.06.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 06:20:58 -0700 (PDT)
Date: Tue, 13 Sep 2016 08:20:55 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH v3 02/15] x86/dumpstack: Add save_stack_trace()_fast()
Message-ID: <20160913132055.3og4jxc4npqa6cfa@treble>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-3-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1473759914-17003-3-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Sep 13, 2016 at 06:45:01PM +0900, Byungchul Park wrote:
> In non-oops case, it's usually not necessary to check all words of stack
> area to extract backtrace. Instead, we can achieve it by tracking frame
> pointer. So made it possible to save stack trace lightly in normal case.
> 
> I measured its ovehead and printed its difference of sched_clock() with
> my QEMU x86 machine. The latency was improved over 80% when
> trace->max_entries = 5.

Again this code will (probably) be obsolete soon.  And another quote
from my previous review:

  So how about we change save_stack_trace() to use print_context_stack()
  for CONFIG_FRAME_POINTER=n and print_context_stack_bp() for
  CONFIG_FRAME_POINTER=y?  That would preserve the existing behavior, no?

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
