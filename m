Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 805116B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 06:24:48 -0400 (EDT)
Message-ID: <4E9D53E9.9020503@profihost.ag>
Date: Tue, 18 Oct 2011 12:24:41 +0200
From: Philipp Herz - Profihost AG <p.herz@profihost.ag>
Reply-To: p.herz@profihost.ag
MIME-Version: 1.0
Subject: Vanilla-Kernel 3 - page allocation failure
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

After updating kernel (x86_64) to stable version 3 there are a few 
messages appearing in the kernel log such as

kworker/0:1: page allocation failure: order:1, mode:0x20
mysql: page allocation failure: order:1, mode:0x20
php5: page allocation failure: order:1, mode:0x20

Searching the net showed that these messages are known to occur since 2004.

Some people were able to get rid of them by setting 
/proc/sys/vm/min_free_kbytes to a high enough value. This does not help 
in our case.


Is there a kernel comand line argument to avoid these messages?

As of mm/page_alloc.c these messages are marked to be only warning 
messages and would not appear if 'gpf_mask' was set to __GFP_NOWARN in 
function warn_alloc_failed.

How does this mask get set? Is it set by the "external" process knocking 
at the memory manager?

What is the magic behind the 'order' and 'mode'?

I'm not a subscriber, so please CC me a copy of messages related to the 
subject. I'm not sure if I can help much by looking at the inside of the 
kernel, but I will try my best to answer any questions concerning this 
issue.

Best regards, Philipp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
