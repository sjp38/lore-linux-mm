Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3709A440441
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 11:40:50 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 128so78219437wmz.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 08:40:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f70si27784574wmd.99.2016.02.05.08.40.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 08:40:49 -0800 (PST)
Date: Fri, 5 Feb 2016 17:40:46 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH v2] floppy: refactor open() flags handling (was Re: mm:
 uninterruptable tasks hanged on mmap_sem)
In-Reply-To: <CACT4Y+bwn9jgXApDbCit8CWm1gzxe6PkTsQitcYdr9z=3Ew3jw@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1602051739331.22727@cbobk.fhfr.pm>
References: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com> <alpine.LNX.2.00.1602042219460.22727@cbobk.fhfr.pm> <CACT4Y+aBCt_pVK+SY9fRpRFU9KTVOChn_vs5pv_KFiUbkGCm4Q@mail.gmail.com> <alpine.LNX.2.00.1602051445520.22727@cbobk.fhfr.pm>
 <CACT4Y+bwn9jgXApDbCit8CWm1gzxe6PkTsQitcYdr9z=3Ew3jw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Takashi Iwai <tiwai@suse.de>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Fri, 5 Feb 2016, Dmitry Vyukov wrote:

> I don't have any objections. And I agree that it does not make sense
> to spend any considerable time on optimizing this driver.

Yeah, on a second thought this definitely is the way how to deal with this 
in this particular driver.

> > Alternatively we can take more conservative aproach, accept the
> > nonblocking flag, but do the regular business of the driver.
> >
> > Actually, let's try that, to make sure that we don't introduce userspace
> > breakage.
> >
> > Could you please retest with the patch below?
> 
> Reapplied.

Thanks. Once/if you confirm that syzkaller is not able to reproduce the 
problem any more, I'll queue it and push to Jens.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
