Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 067776B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 09:18:07 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id e2so48243670ybi.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 06:18:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o5si4765114qtb.140.2016.09.13.06.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 06:18:06 -0700 (PDT)
Date: Tue, 13 Sep 2016 08:18:02 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH v3 01/15] x86/dumpstack: Optimize save_stack_trace
Message-ID: <20160913131802.oiwxgpmccn7uufef@treble>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-2-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1473759914-17003-2-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Sep 13, 2016 at 06:45:00PM +0900, Byungchul Park wrote:
> Currently, x86 implementation of save_stack_trace() is walking all stack
> region word by word regardless of what the trace->max_entries is.
> However, it's unnecessary to walk after already fulfilling caller's
> requirement, say, if trace->nr_entries >= trace->max_entries is true.
> 
> I measured its overhead and printed its difference of sched_clock() with
> my QEMU x86 machine. The latency was improved over 70% when
> trace->max_entries = 5.

This code will (probably) be obsoleted soon with my new unwinder.

Also, my previous comment was ignored:

  Instead of adding a new callback, why not just check the ops->address()
  return value?  It already returns an error if the array is full. 
   
  I think that would be cleaner and would help prevent more callback
  sprawl.

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
