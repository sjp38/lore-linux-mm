Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AC1D06B0047
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 11:57:07 -0500 (EST)
Message-ID: <4B71927D.6030607@nortel.com>
Date: Tue, 09 Feb 2010 10:51:09 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: tracking memory usage/leak in "inactive" field in /proc/meminfo?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm hoping you can help me out.  I'm on a 2.6.27 x86 system and I'm
seeing the "inactive" field in /proc/meminfo slowly growing over time to
the point where eventually the oom-killer kicks in and starts killing
things.  The growth is not evident in any other field in /proc/meminfo.

I'm trying to figure out where the memory is going, and what it's being
used for.

As I've found, the fields in /proc/meminfo don't add up...in particular,
active+inactive is quite a bit larger than
buffers+cached+dirty+anonpages+mapped+pagetables+vmallocused.  Initially
the difference is about 156MB, but after about 13 hrs the difference is
240MB.

How can I track down where this is going?  Can you suggest any
instrumentation that I can add?

I'm reasonably capable, but I'm getting seriously confused trying to
sort out the memory subsystem.  Some pointers would be appreciated.

Thanks,

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
