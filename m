Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 018CC6B003D
	for <linux-mm@kvack.org>; Mon,  9 Feb 2009 08:44:22 -0500 (EST)
Received: by ewy14 with SMTP id 14so565002ewy.14
        for <linux-mm@kvack.org>; Mon, 09 Feb 2009 05:44:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1233934630.17551.1.camel@think.oraclecorp.com>
References: <a4423d670902060710m4919f6d6p1ffae13859c891be@mail.gmail.com>
	 <1233934630.17551.1.camel@think.oraclecorp.com>
Date: Mon, 9 Feb 2009 16:44:20 +0300
Message-ID: <a4423d670902090544g7b7dbe9aj415141c46d1fc95f@mail.gmail.com>
Subject: Re: next-20090206: kernel BUG at mm/slub.c:1132
From: Alexander Beregalov <a.beregalov@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

2009/2/6 Chris Mason <chris.mason@oracle.com>:
> On Fri, 2009-02-06 at 18:10 +0300, Alexander Beregalov wrote:
>> Hi
>>
>> I run dbench on btrfs, which is on file on xfs
>>
>> btrfs: disabling barriers on dev /dev/loop/0
>> ------------[ cut here ]------------
>> kernel BUG at mm/slub.c:1132!
>> invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> last sysfs file: /sys/kernel/uevent_seqnum
>
> Btrfs hammers on slab caches quite a lot, can you reproduce this without
> loop or without btrfs?
Hi Chris

No, I can not reproduce it without loop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
