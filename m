Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8476B02A7
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 12:03:50 -0400 (EDT)
Date: Fri, 9 Jul 2010 12:03:42 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] Add trace events to mmap and brk
Message-ID: <20100709160342.GB3281@infradead.org>
References: <1278690830-22145-1-git-send-email-emunson@mgebm.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278690830-22145-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hmm, thinking about it a bit more, what do you trace events give us that
the event based syscall tracer doesn't?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
