Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 91F815F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 17:06:02 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9818D82C2F0
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 17:16:01 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sHZaHDjiY6jf for <linux-mm@kvack.org>;
	Thu, 16 Apr 2009 17:16:01 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 76BBE82C308
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 17:15:55 -0400 (EDT)
Date: Thu, 16 Apr 2009 16:58:56 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: how to tell if arbitrary kernel memory address is backed by
 physical memory?
In-Reply-To: <49E750CA.4060300@nortel.com>
Message-ID: <alpine.DEB.1.10.0904161654480.7855@qirst.com>
References: <49E750CA.4060300@nortel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Apr 2009, Chris Friesen wrote:

> Quick question to the memory management folks.
>
> Is there a portable way to tell whether a particular virtual address in the
> lowmem address range is backed by physical memory and is readable?
>
> For background...we have some guys working on a software memory scrubber for
> an embedded board.  The memory controller supports ECC but doesn't support
> scrubbing  in hardware.  What we want to do is walk all of lowmem, reading in
> memory.  If a fault is encountered, it will be handled by other code.

Virtual address in the lowmem address range? lowmem address ranges exist
for physical addresses.

If you walk lowmem (physical) then you will never see a missing page.

So I guess you have a process that wants to determine if its memory is
present? See

	man 2 mincore

which describes a glibc call that shows which pages of a process are
present.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
