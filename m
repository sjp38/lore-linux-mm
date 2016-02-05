Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B03F5440441
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 16:16:26 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so44377866wme.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 13:16:26 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id g2si26540261wje.67.2016.02.05.13.16.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 13:16:25 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id g62so44377475wme.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 13:16:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1602051739331.22727@cbobk.fhfr.pm>
References: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com>
 <alpine.LNX.2.00.1602042219460.22727@cbobk.fhfr.pm> <CACT4Y+aBCt_pVK+SY9fRpRFU9KTVOChn_vs5pv_KFiUbkGCm4Q@mail.gmail.com>
 <alpine.LNX.2.00.1602051445520.22727@cbobk.fhfr.pm> <CACT4Y+bwn9jgXApDbCit8CWm1gzxe6PkTsQitcYdr9z=3Ew3jw@mail.gmail.com>
 <alpine.LNX.2.00.1602051739331.22727@cbobk.fhfr.pm>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 5 Feb 2016 22:16:05 +0100
Message-ID: <CACT4Y+Zb1Ne15MTyu6KMTD+FtFQob1UPg-mHDmTS3c6F5rNJ=A@mail.gmail.com>
Subject: Re: [PATCH v2] floppy: refactor open() flags handling (was Re: mm:
 uninterruptable tasks hanged on mmap_sem)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Takashi Iwai <tiwai@suse.de>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Fri, Feb 5, 2016 at 5:40 PM, Jiri Kosina <jikos@kernel.org> wrote:
> On Fri, 5 Feb 2016, Dmitry Vyukov wrote:
>
>> I don't have any objections. And I agree that it does not make sense
>> to spend any considerable time on optimizing this driver.
>
> Yeah, on a second thought this definitely is the way how to deal with this
> in this particular driver.
>
>> > Alternatively we can take more conservative aproach, accept the
>> > nonblocking flag, but do the regular business of the driver.
>> >
>> > Actually, let's try that, to make sure that we don't introduce userspace
>> > breakage.
>> >
>> > Could you please retest with the patch below?
>>
>> Reapplied.
>
> Thanks. Once/if you confirm that syzkaller is not able to reproduce the
> problem any more, I'll queue it and push to Jens.


Tested. Fixes the hang for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
