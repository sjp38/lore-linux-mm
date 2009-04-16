Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4BEF95F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 11:37:20 -0400 (EDT)
Message-ID: <49E750CA.4060300@nortel.com>
Date: Thu, 16 Apr 2009 09:37:46 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: how to tell if arbitrary kernel memory address is backed by physical
 memory?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi all,

Quick question to the memory management folks.

Is there a portable way to tell whether a particular virtual address in 
the lowmem address range is backed by physical memory and is readable?

For background...we have some guys working on a software memory scrubber 
for an embedded board.  The memory controller supports ECC but doesn't 
support scrubbing  in hardware.  What we want to do is walk all of 
lowmem, reading in memory.  If a fault is encountered, it will be 
handled by other code.

Thanks,

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
