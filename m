Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 32A3A6006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 13:48:20 -0400 (EDT)
Subject: Re: [PATCH] Add trace event for munmap
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100708173515.GA11652@infradead.org>
References: <1278597931-26855-1-git-send-email-emunson@mgebm.net>
	 <1278598955.1900.152.camel@laptop> <20100708144407.GA8141@us.ibm.com>
	 <20100708173515.GA11652@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 08 Jul 2010 19:48:08 +0200
Message-ID: <1278611288.1900.164.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Eric B Munson <ebmunson@us.ibm.com>, Eric B Munson <emunson@mgebm.net>, akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, anton@samba.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-08 at 13:35 -0400, Christoph Hellwig wrote:

> What kind of infrastructure is perf using for recording
> mmap()/mremap()/brk() information?

A direct hook into mmap_region(), see perf_event_mmap().

We used to only track VM_EXEC regions, but these days we can also track
data regions (although it wouldn't track mremap and brk I think).

We need the VM_EXEC maps to make sense of the instruction pointer
samples.

Eric recently added support for !VM_EXEC mmap() in order to interpret
linear addresses provided by things like the software pagefault events
and certain powerpc hardware events.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
