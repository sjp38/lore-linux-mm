Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7D86B00C2
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 07:26:42 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so564997pbc.22
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 04:26:42 -0700 (PDT)
Received: from psmtp.com ([74.125.245.157])
        by mx.google.com with SMTP id hb3si4819021pac.152.2013.10.25.04.26.40
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 04:26:41 -0700 (PDT)
Date: Fri, 25 Oct 2013 04:26:37 -0700 (PDT)
From: David Lang <david@lang.hm>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
In-Reply-To: <20131025214952.3eb41201@notabene.brown>
Message-ID: <alpine.DEB.2.02.1310250425270.22538@nftneq.ynat.uz>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07> <20131025214952.3eb41201@notabene.brown>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org

On Fri, 25 Oct 2013, NeilBrown wrote:

> On Fri, 25 Oct 2013 07:25:13 +0000 (UTC) "Artem S. Tashkinov"
> <t.artem@lycos.com> wrote:
>
>> Hello!
>>
>> On my x86-64 PC (Intel Core i5 2500, 16GB RAM), I have the same 3.11 kernel
>> built for the i686 (with PAE) and x86-64 architectures. What's really troubling me
>> is that the x86-64 kernel has the following problem:
>>
>> When I copy large files to any storage device, be it my HDD with ext4 partitions
>> or flash drive with FAT32 partitions, the kernel first caches them in memory entirely
>> then flushes them some time later (quite unpredictably though) or immediately upon
>> invoking "sync".
>>
>> How can I disable this memory cache altogether (or at least minimize caching)? When
>> running the i686 kernel with the same configuration I don't observe this effect - files get
>> written out almost immediately (for instance "sync" takes less than a second, whereas
>> on x86-64 it can take a dozen of _minutes_ depending on a file size and storage
>> performance).
>
> What exactly is bothering you about this?  The amount of memory used or the
> time until data is flushed?

actually, I think the problem is more the impact of the huge write later on.

David Lang

> If the later, then /proc/sys/vm/dirty_expire_centisecs is where you want to
> look.
> This defaults to 30 seconds (3000 centisecs).
> You could make it smaller (providing you also shrink
> dirty_writeback_centisecs in a similar ratio) and the VM will flush out data
> more quickly.
>
> NeilBrown
>
>
>>
>> I'm _not_ talking about disabling write cache on my storage itself (hdparm -W 0 /dev/XXX)
>> - firstly this command is detrimental to the performance of my PC, secondly, it won't help
>> in this instance.
>>
>> Swap is totally disabled, usually my memory is entirely free.
>>
>> My kernel configuration can be fetched here: https://bugzilla.kernel.org/show_bug.cgi?id=63531
>>
>> Please, advise.
>>
>> Best regards,
>>
>> Artem
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
