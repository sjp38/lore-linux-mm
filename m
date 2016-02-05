Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD874403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 09:27:19 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id r129so29104935wmr.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 06:27:19 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id e15si24457434wjq.241.2016.02.05.06.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 06:27:18 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id 128so72894821wmz.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 06:27:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1602051445520.22727@cbobk.fhfr.pm>
References: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com>
 <alpine.LNX.2.00.1602042219460.22727@cbobk.fhfr.pm> <CACT4Y+aBCt_pVK+SY9fRpRFU9KTVOChn_vs5pv_KFiUbkGCm4Q@mail.gmail.com>
 <alpine.LNX.2.00.1602051445520.22727@cbobk.fhfr.pm>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 5 Feb 2016 15:26:58 +0100
Message-ID: <CACT4Y+bwn9jgXApDbCit8CWm1gzxe6PkTsQitcYdr9z=3Ew3jw@mail.gmail.com>
Subject: Re: [PATCH v2] floppy: refactor open() flags handling (was Re: mm:
 uninterruptable tasks hanged on mmap_sem)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Takashi Iwai <tiwai@suse.de>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Fri, Feb 5, 2016 at 2:51 PM, Jiri Kosina <jikos@kernel.org> wrote:
> On Fri, 5 Feb 2016, Dmitry Vyukov wrote:
>
>> > could you please feed the patch below (on top of the previous floppy fix)
>> > to your syzkaller machinery and test whether you are still able to
>> > reproduce the problem? It passess my local testing here.
>>
>> Now that open exits early with EWOULDBLOCK, I guess the reproduced is
>> not doing anything particularly interesting.
>
> Yeah. But as I explained in the changelog, I think it's a valid thing to
> do (opinions welcome).
>
> I don't think having a huge discussion about what nonblocking really means
> for floppy and then try to refactor the whole driver to support that would
> make sense.

I don't have any objections. And I agree that it does not make sense
to spend any considerable time on optimizing this driver.


> Alternatively we can take more conservative aproach, accept the
> nonblocking flag, but do the regular business of the driver.
>
> Actually, let's try that, to make sure that we don't introduce userspace
> breakage.
>
> Could you please retest with the patch below?

Reapplied.
Agree that it's better to not bail out on O_NONBLOCK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
