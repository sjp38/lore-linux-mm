Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B76C36B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 15:26:13 -0500 (EST)
Message-ID: <4B69DAAB.9070301@nortel.com>
Date: Wed, 03 Feb 2010 14:20:59 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Need help tracking down memory consumption increase
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm seeing a slow increase in memory consumption and I'm trying to
narrow down the possible causes.

In my test, I got the system into steady-state and then started
monitoring /proc/meminfo.

After 14 hrs:
MemFree had dropped by 594MB.
Active + Inactive + Slab increased by 594MB
Buffers + Cached + AnonPages + Mapped + Slab increased by 290MB

The other categories in /proc/meminfo didn't change significantly.

I've done some experimenting and it seems that pages allocated in the
kernel via alloc_page() and friends don't show up in /proc/meminfo
except that they're deducted from the MemFree category.  Specifically,
they don't seem to show up in the Active/Inactive category.  Can someone
confirm this?

Given the above, what types of pages are in Active/Inactive other than
Buffers + Cached + AnonPages + Mapped?

Thanks,

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
