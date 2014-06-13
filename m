Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1B53E6B00CD
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 10:20:28 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id dc16so3717076qab.1
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 07:20:27 -0700 (PDT)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id z3si506547qad.10.2014.06.13.07.20.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 07:20:27 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id j15so3570489qaq.40
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 07:20:27 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <CANq1E4R2K+eq9AxtFewp4YUL2cujg+dg+sN19Anvf-zWuvgyWw@mail.gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
 <1402655819-14325-4-git-send-email-dh.herrmann@gmail.com> <CAKgNAkgnnWjrbE+2KAETsmiyrnrMQu0h7-MrYLvkiwj--_nxcQ@mail.gmail.com>
 <CANq1E4R2K+eq9AxtFewp4YUL2cujg+dg+sN19Anvf-zWuvgyWw@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Fri, 13 Jun 2014 16:20:07 +0200
Message-ID: <CAKgNAkgMA39AfoSoA5Pe1r9N+ZzfYQNvNPvcRN7tOvRb8+v06Q@mail.gmail.com>
Subject: Re: [PATCH v3 3/7] shm: add memfd_create() syscall
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

Hi David,

On Fri, Jun 13, 2014 at 2:41 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> Hi
>
> On Fri, Jun 13, 2014 at 2:27 PM, Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> Hi David,
>>
>> On Fri, Jun 13, 2014 at 12:36 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
>>> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
>>> that you can pass to mmap(). It can support sealing and avoids any
>>> connection to user-visible mount-points. Thus, it's not subject to quotas
>>> on mounted file-systems, but can be used like malloc()'ed memory, but
>>> with a file-descriptor to it.
>>>
>>> memfd_create() returns the raw shmem file, so calls like ftruncate() can
>>> be used to modify the underlying inode. Also calls like fstat()
>>> will return proper information and mark the file as regular file. If you
>>> want sealing, you can specify MFD_ALLOW_SEALING. Otherwise, sealing is not
>>> supported (like on all other regular files).
>>>
>>> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
>>> subject to quotas and alike. It is still properly accounted to memcg
>>> limits, though.
>>
>> Where do I find / is there detailed documentation (ideally, a man
>> page) for this new system call?
>
> I did write a man-page proposal for memfd_create() and a patch for
> fcntl() for v1,

Ahh -- that's why I had a recollection of such a page ;-).

> however, the API changed several times so I didn't
> keep them up to date (the man-page patches are on LKML). However, I
> wrote a short introduction to memfd+sealing v3, that I recommend
> reading first:
>   http://dvdhrm.wordpress.com/2014/06/10/memfd_create2/

Yes, I saw it already. (It's good, but I want more.)

> This explains the idea behind the new API and describes almost all
> aspects of it. It's up-to-date to v3 and I will use it to write the
> final man-pages once Hugh and Andrew ACKed the patches. Let me know if
> anything is unclear.

The general notion these days is that a (comprehensive) manual page
_should_ come *with* the system call, rather than after the fact. And
there's a lot of value in that. I've found no end of bugs and design
errors while writing (comprehensive) man pages after the fact (by
which time it's too late to fix the design errors), and also found
quite a few of those issues when I've managed to work with folk at the
same time as they write the syscall. Bottom line: you really should
write formal documentation now, as part of the process of code
submission. It improves the chance of finding implementation and
design bugs, and may well widen your circle of reviewers.

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
