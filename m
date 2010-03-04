Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A3A466B007E
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 09:41:55 -0500 (EST)
Message-ID: <4B8FC6AC.4060801@teksavvy.com>
Date: Thu, 04 Mar 2010 09:41:48 -0500
From: Mark Lord <kernel@teksavvy.com>
MIME-Version: 1.0
Subject: Re: Linux kernel - Libata bad block error handling to user mode
 program
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org> <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>
In-Reply-To: <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Freemyer <greg.freemyer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, foo saa <foosaa@gmail.com>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/04/10 09:17, Greg Freemyer wrote:
..
> I think / suspect your major problem is you say above that you use a
> 512-byte buffer to wipe with.  The kernel is using 4K pages.  So when
> you write to a 4K section of the drive for the first time, the kernel
> implements read-modify-write logic.
>
> Your i/o failures are almost certainly on the read cycle of the above,
> not the write cycle.  You need to move to 4K buffers and you need to
> ensure your 4K writes are aligned with how the kernel is working with
> the disk.  ie. You need your 4K buffer to perfectly align with the
> kernels 4K block handling so you never have a read-modify-write cycle.
..

You'll also need to disable Linux read-ahead for the drive,
or it may try reading beyond even the 4KB block.

But really.. isn't "hdparm --security-erase NULL /dev/sdX" good enough ???

Cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
