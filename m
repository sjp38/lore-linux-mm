Message-ID: <380375A4.B5887095@colorfullife.com>
Date: Tue, 12 Oct 1999 19:53:40 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: vma_list_sem
References: <Pine.LNX.4.10.9910121943300.17128-100000@clmsdevli>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: viro@math.psu.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

manfreds wrote:
> I found one more find_vma() caller which performs no locking:
> fs/super.c: copy_mount_options().
> 
I overlooked a stupid bug in copy_mount_options(), it can return without
releasing the mm semaphore.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
