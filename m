Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AAFF96B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 10:37:20 -0500 (EST)
Subject: Re: next-20090206: kernel BUG at mm/slub.c:1132
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <a4423d670902060710m4919f6d6p1ffae13859c891be@mail.gmail.com>
References: <a4423d670902060710m4919f6d6p1ffae13859c891be@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 06 Feb 2009 10:37:10 -0500
Message-Id: <1233934630.17551.1.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexander Beregalov <a.beregalov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-02-06 at 18:10 +0300, Alexander Beregalov wrote:
> Hi
> 
> I run dbench on btrfs, which is on file on xfs
> 
> btrfs: disabling barriers on dev /dev/loop/0
> ------------[ cut here ]------------
> kernel BUG at mm/slub.c:1132!
> invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> last sysfs file: /sys/kernel/uevent_seqnum

Btrfs hammers on slab caches quite a lot, can you reproduce this without
loop or without btrfs?

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
