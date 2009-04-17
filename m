Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4357A5F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 12:34:26 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 82E3A82C380
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 12:44:57 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7O5rbxxPATQM for <linux-mm@kvack.org>;
	Fri, 17 Apr 2009 12:44:57 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4E7F282C39B
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 12:44:51 -0400 (EDT)
Date: Fri, 17 Apr 2009 12:27:43 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: how to tell if arbitrary kernel memory address is backed by
 physical memory?
In-Reply-To: <49E8AB11.4000708@nortel.com>
Message-ID: <alpine.DEB.1.10.0904171224530.7261@qirst.com>
References: <49E750CA.4060300@nortel.com> <alpine.DEB.1.10.0904161654480.7855@qirst.com> <49E8AB11.4000708@nortel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 17 Apr 2009, Chris Friesen wrote:

> We have a mips board that appears to have holes in the lowmem mappings such
> that blindly walking all of it causes problems.  I assume the allocator knows
> about these holes and simply doesn't assign memory at those addresses.

Yes memory is registered in distinct ranges during boot.

> We may have found a solution though...it looks like virt_addr_valid() returns
> false for the problematic addresses.  Would it be reasonable to call this once
> for each page before trying to access it?

Sure. Note that virt_addr_valid only ensures that there is a page
struct for that address. You may need to ensure that PageReserved(page) is
false if you want to make sure that you have actual memory there that is
valid to use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
