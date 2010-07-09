Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE63B6B024D
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 12:03:04 -0400 (EDT)
Date: Fri, 9 Jul 2010 12:02:52 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] Add trace point to mremap
Message-ID: <20100709160252.GA3281@infradead.org>
References: <1278690830-22145-1-git-send-email-emunson@mgebm.net>
 <1278690830-22145-2-git-send-email-emunson@mgebm.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278690830-22145-2-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 09, 2010 at 04:53:50PM +0100, Eric B Munson wrote:
> This patch completes the trace point addition to the [m|mre|mun]map
> and brk functions.  These trace points will be used by a userspace
> tool that models application memory usage.

Please keep all the trace events for the mmap family of syscalls in
one subsystem identifier / header file as they're closely related.

I'd prefer to have them all in the mmap one, not mm but that's
debatable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
