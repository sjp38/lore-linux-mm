Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 85C086B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 02:10:10 -0500 (EST)
Message-ID: <4EC361C0.7040309@redhat.com>
Date: Wed, 16 Nov 2011 15:09:52 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] tmpfs: add fallocate support
References: <1321346525-10187-1-git-send-email-amwang@redhat.com> <CAOJsxLEXbWbEhqX2YfzcQhyLJrY0H2ifCJCvGkoFHZsYAZEMPA@mail.gmail.com>
In-Reply-To: <CAOJsxLEXbWbEhqX2YfzcQhyLJrY0H2ifCJCvGkoFHZsYAZEMPA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, kay.sievers@vrfy.org

ao? 2011a1'11ae??15ae?JPY 19:23, Pekka Enberg a??e??:
> Hello,
>
> On Tue, Nov 15, 2011 at 10:42 AM, Amerigo Wang<amwang@redhat.com>  wrote:
>> This patch adds fallocate support to tmpfs. I tested this patch
>> with the following test case,
>>
>>         % sudo mount -t tmpfs -o size=100 tmpfs /mnt
>>         % touch /mnt/foobar
>>         % echo hi>  /mnt/foobar
>>         % fallocate -o 3 -l 5000 /mnt/foobar
>>         fallocate: /mnt/foobar: fallocate failed: No space left on device
>>         % fallocate -o 3 -l 3000 /mnt/foobar
>>         % ls -l /mnt/foobar
>>         -rw-rw-r-- 1 wangcong wangcong 3003 Nov 15 16:10 /mnt/foobar
>>         % dd if=/dev/zero of=/mnt/foobar seek=3 bs=1 count=3000
>>         3000+0 records in
>>         3000+0 records out
>>         3000 bytes (3.0 kB) copied, 0.0153224 s, 196 kB/s
>>         % hexdump -C /mnt/foobar
>>         00000000  68 69 0a 00 00 00 00 00  00 00 00 00 00 00 00 00  |hi..............|
>>         00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
>>         *
>>         00000bb0  00 00 00 00 00 00 00 00  00 00 00                 |...........|
>>         00000bbb
>>         % cat /mnt/foobar
>>         hi
>>
>> Signed-off-by: WANG Cong<amwang@redhat.com>
>
> What's the use case for this?
>

Hi, Pekka,

Systemd needs it, see http://lkml.org/lkml/2011/10/20/275.
I am adding Kay into Cc.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
