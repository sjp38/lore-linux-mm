Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9266C6B01B2
	for <linux-mm@kvack.org>; Sun, 23 May 2010 14:32:58 -0400 (EDT)
Message-ID: <4BF974D5.30207@cesarb.net>
Date: Sun, 23 May 2010 15:32:53 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: Swap checksum
References: <4BF81D87.6010506@cesarb.net> <20100523140348.GA10843@barrios-desktop>
In-Reply-To: <20100523140348.GA10843@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Em 23-05-2010 11:03, Minchan Kim escreveu:
> On Sat, May 22, 2010 at 03:08:07PM -0300, Cesar Eduardo Barros wrote:
>> Add support for checksumming the swap pages written to disk, using the
>> same checksum as btrfs (crc32c). Since the contents of the swap do not
>> matter after a shutdown, the checksum is kept in memory only.
>>
>> Note that this code does not checksum the software suspend image.
> We have been used swap pages without checksum.
>
> First of all, Could you explain why you need checksum on swap pages?
> Do you see any problem which swap pages are broken?

The same reason we need checksums in the filesystem.

If you use btrfs as your root filesystem, you are protected by checksums 
from damage in the filesystem, but not in the swap partition (which is 
often in the same disk, and thus as vulnerable as the filesystem). It is 
better to get a checksum error when swapping in than having a silently 
corrupted page.

If you add checksums to the swap, the only piece missing (besides the 
partition table and bootloader, and the first one is solved by GPT, 
which also has a checksum) is checksumming the software suspend image. 
But it has a differente read/write path and different requirements (to 
start with, the checksums must be written to the disk too, while for the 
swap they can stay in memory only).

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
