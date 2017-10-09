Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3A0B6B0033
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 15:11:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i124so26729435wmf.7
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 12:11:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v109sor3005661wrb.25.2017.10.09.12.11.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 12:11:45 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <1507576124.21121.168.camel@redhat.com>
References: <20170914130040.6faabb18@cuia.usersys.redhat.com>
 <CAAF6GDdnY2AmzKx+t4ffCFxJ+RZS++4tmWvoazdVNVSYjra_WA@mail.gmail.com>
 <20170914150546.74ad3a9a@cuia.usersys.redhat.com> <a1715d1d-7a03-d2db-7a8a-8a2edceae5d1@gmail.com>
 <1505848907.5486.9.camel@redhat.com> <CAKgNAkg8QJHfPfdfYXBU2-eW=_FWY99UYi_6hQejE=q5+66u1g@mail.gmail.com>
 <1507576124.21121.168.camel@redhat.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Mon, 9 Oct 2017 21:11:24 +0200
Message-ID: <CAKgNAkjGX5BanVCB=fauy9tYt+eAOb990LDOd73dvUp-bm03KA@mail.gmail.com>
Subject: Re: [patch v2] madvise.2: Add MADV_WIPEONFORK documentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: =?UTF-8?Q?Colm_MacC=C3=A1rthaigh?= <colm@allcosts.net>, linux-man <linux-man@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, nilal@redhat.com, Florian Weimer <fweimer@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hi Rik,

Thanks for the blazingly fast response :-)

On 9 October 2017 at 21:08, Rik van Riel <riel@redhat.com> wrote:
> On Mon, 2017-10-09 at 21:06 +0200, Michael Kerrisk (man-pages) wrote:
>> Hi Rik,
>>
>> I have a follow-up question re wipe-on-fork. What are the semantics
>> for this setting with respect to fork() and exec()? That is, in the
>> child of a fork(), does the flag remain set for the specified address
>> range? (My quick read of the source suggests yes, but I have not
>> tested.) And, when we do an exec(), my assumption is that the flag is
>> cleared for the address range, but it would be good to have
>> confirmation.
>
> Indeed, on exec() the flag is cleared, because all
> memory regions get replaced on exec().

Thanks.

> The flag remains across a fork(), so if a child task
> were to fork, the memory would be empty of contents
> again in its child. This seems to most closely match
> the use case of discarding things like cryptographic
> secrets at fork time.

Thanks!

I'll add this info to the madvise(2) page.

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
