Date: Fri, 11 Aug 2006 02:16:26 -0700
Message-Id: <200608110916.k7B9GQWw023318@zach-dev.vmware.com>
Subject: [PATCH 0/9] i386 MMU paravirtualization patches
From: Zachary Amsden <zach@vmware.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, Zachary Amsden <zach@vmware.com>, Chris Wright <chrisw@osdl.org>, Rusty Russell <rusty@rustcorp.com.au>, Jeremy Fitzhardinge <jeremy@goop.org>, Virtualization Mailing List <virtualization@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>Zachary Amsden <zach@vmware.com>
List-ID: <linux-mm.kvack.org>

These patches provide the infrastructure for paravirtualized MMU operations
while at the same time cleaning up and optimizing the pagetable accessors for
i386.  They should be largely uncontroversial and are well tested.  There are
still some performance gains to be had for paravirtualization, but it is more
important to get the native code base that will enable them checked in first.

Zach

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
