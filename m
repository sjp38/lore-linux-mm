Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 54C816B00DD
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 03:25:17 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so3591579pdj.22
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 00:25:16 -0700 (PDT)
Received: from psmtp.com ([74.125.245.157])
        by mx.google.com with SMTP id ud7si4215175pac.149.2013.10.25.00.25.15
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 00:25:16 -0700 (PDT)
Date: Fri, 25 Oct 2013 07:25:13 +0000 (UTC)
From: "Artem S. Tashkinov" <t.artem@lycos.com>
Message-ID: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
Subject: Disabling in-memory write cache for x86-64 in Linux II
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org

Hello!

On my x86-64 PC (Intel Core i5 2500, 16GB RAM), I have the same 3.11 kernel
built for the i686 (with PAE) and x86-64 architectures. What's really troubling me
is that the x86-64 kernel has the following problem:

When I copy large files to any storage device, be it my HDD with ext4 partitions
or flash drive with FAT32 partitions, the kernel first caches them in memory entirely
then flushes them some time later (quite unpredictably though) or immediately upon
invoking "sync".

How can I disable this memory cache altogether (or at least minimize caching)? When
running the i686 kernel with the same configuration I don't observe this effect - files get
written out almost immediately (for instance "sync" takes less than a second, whereas
on x86-64 it can take a dozen of _minutes_ depending on a file size and storage
performance).

I'm _not_ talking about disabling write cache on my storage itself (hdparm -W 0 /dev/XXX)
- firstly this command is detrimental to the performance of my PC, secondly, it won't help
in this instance.

Swap is totally disabled, usually my memory is entirely free.

My kernel configuration can be fetched here: https://bugzilla.kernel.org/show_bug.cgi?id=63531

Please, advise.

Best regards,

Artem 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
