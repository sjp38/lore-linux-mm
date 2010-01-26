Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 562106B009A
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 14:09:08 -0500 (EST)
Message-ID: <4B5F3C9C.3050908@nortel.com>
Date: Tue, 26 Jan 2010 13:03:56 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: which fields in /proc/meminfo are orthogonal?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi,

We have a system (2.6.27 based) which seems to be increasing its memory
consumption by several MB an hour.  Summing up Pss for all maps in all
processes doesn't seem to explain it, so I'm looking at the kernel.

I've backported the kmemleak functionality.  It's self-test module shows
leaks so I know it's working, but it doesn't report any leaks that would
correspond to the memory increase.

I'm currently trying to figure out which of the entries in /proc/meminfo
are actually orthogonal to each other.  Ideally I'd like to be able to
add up the suitable entries and have it work out to the total memory on
the system, so that I can then narrow down exactly where the memory is
going.  Is this feasable?

I'll keep reading the code but if anyone happens to know this already
I'd appreciate some assistance.

Thanks,

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
