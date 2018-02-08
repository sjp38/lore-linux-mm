Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC4DD6B0005
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 12:18:10 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id b6so133552plx.3
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 09:18:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o33-v6sor131379plb.85.2018.02.08.09.18.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 09:18:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <22e5e2e1-fd64-1a75-a80c-332a34266717@virtuozzo.com>
References: <001a11447070ac6fcb0564a08cb1@google.com> <20180207155229.GC10945@tassilo.jf.intel.com>
 <20180208092839.ebe5rk6mtvkk5da4@quack2.suse.cz> <CACT4Y+ZTNDhEhAAP2PYRH5WxEeEM0xHdp4UKqtNaWhU6w4sj_g@mail.gmail.com>
 <20180208140833.lpr4yjn7g3v3cdy3@quack2.suse.cz> <CACT4Y+bwnyFmgTNMTa1p8WKecH=OU5Za_hboY7Q=V2Aq+DOsKQ@mail.gmail.com>
 <20180208161821.f7x3gopytdtzgf65@quack2.suse.cz> <22e5e2e1-fd64-1a75-a80c-332a34266717@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 8 Feb 2018 18:17:48 +0100
Message-ID: <CACT4Y+b8CzoTXTitPX-O83p5zgEjsR37U3TPyQ0=4fGeNJHdiA@mail.gmail.com>
Subject: Re: INFO: task hung in sync_blockdev
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, syzbot <syzbot+283c3c447181741aea28@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, linux-fsdevel@vger.kernel.org

On Thu, Feb 8, 2018 at 5:23 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
> On 02/08/2018 07:18 PM, Jan Kara wrote:
>
>>> By "full kernel crashdump" you mean kdump thing, or something else?
>>
>> Yes, the kdump thing (for KVM guest you can grab the memory dump also from
>> the host in a simplier way and it should be usable with the crash utility
>> AFAIK).
>>
>
> In QEMU monitor 'dump-guest-memory' command:
>
> (qemu) help dump-guest-memory
> dump-guest-memory [-p] [-d] [-z|-l|-s] filename [begin length] -- dump guest memory into file 'filename'.
>                         -p: do paging to get guest's memory mapping.
>                         -d: return immediately (do not wait for completion).
>                         -z: dump in kdump-compressed format, with zlib compression.
>                         -l: dump in kdump-compressed format, with lzo compression.
>                         -s: dump in kdump-compressed format, with snappy compression.
>                         begin: the starting physical address.
>                         length: the memory size, in bytes


Nice!
Do you know straight away if it's scriptable/automatable? Or do I just
send some magic sequence of bytes representing ^A+C,
dump-guest-memory, \n to stdin pipe?

Unfortunately, syzbot uses GCE VMs for testing, and there does not
seem to be such feature on GCE...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
