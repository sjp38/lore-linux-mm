Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 516056B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 14:39:49 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id tr6so683442ieb.36
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 11:39:49 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id k4si4178197igx.63.2014.07.08.11.39.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 11:39:48 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id r10so1073509igi.0
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 11:39:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKgNAkgMA39AfoSoA5Pe1r9N+ZzfYQNvNPvcRN7tOvRb8+v06Q@mail.gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<1402655819-14325-4-git-send-email-dh.herrmann@gmail.com>
	<CAKgNAkgnnWjrbE+2KAETsmiyrnrMQu0h7-MrYLvkiwj--_nxcQ@mail.gmail.com>
	<CANq1E4R2K+eq9AxtFewp4YUL2cujg+dg+sN19Anvf-zWuvgyWw@mail.gmail.com>
	<CAKgNAkgMA39AfoSoA5Pe1r9N+ZzfYQNvNPvcRN7tOvRb8+v06Q@mail.gmail.com>
Date: Tue, 8 Jul 2014 20:39:47 +0200
Message-ID: <CANq1E4RYWb9WbXD+Vj0SYDAZqym4mc4u6+HQJbjDeS+wQeG2Uw@mail.gmail.com>
Subject: Re: [PATCH v3 3/7] shm: add memfd_create() syscall
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk-manpages <mtk.manpages@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

Hi

On Fri, Jun 13, 2014 at 4:20 PM, Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> Hi David,
>
> On Fri, Jun 13, 2014 at 2:41 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
>> Hi
>>
>> On Fri, Jun 13, 2014 at 2:27 PM, Michael Kerrisk (man-pages)
>> <mtk.manpages@gmail.com> wrote:
>>> Hi David,
>>>
>>> On Fri, Jun 13, 2014 at 12:36 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
>>>> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
>>>> that you can pass to mmap(). It can support sealing and avoids any
>>>> connection to user-visible mount-points. Thus, it's not subject to quotas
>>>> on mounted file-systems, but can be used like malloc()'ed memory, but
>>>> with a file-descriptor to it.
>>>>
>>>> memfd_create() returns the raw shmem file, so calls like ftruncate() can
>>>> be used to modify the underlying inode. Also calls like fstat()
>>>> will return proper information and mark the file as regular file. If you
>>>> want sealing, you can specify MFD_ALLOW_SEALING. Otherwise, sealing is not
>>>> supported (like on all other regular files).
>>>>
>>>> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
>>>> subject to quotas and alike. It is still properly accounted to memcg
>>>> limits, though.
>>>
>>> Where do I find / is there detailed documentation (ideally, a man
>>> page) for this new system call?
>>
>> I did write a man-page proposal for memfd_create() and a patch for
>> fcntl() for v1,
>
> Ahh -- that's why I had a recollection of such a page ;-).
>
>> however, the API changed several times so I didn't
>> keep them up to date (the man-page patches are on LKML). However, I
>> wrote a short introduction to memfd+sealing v3, that I recommend
>> reading first:
>>   http://dvdhrm.wordpress.com/2014/06/10/memfd_create2/
>
> Yes, I saw it already. (It's good, but I want more.)

Sorry, totally forgot about that one. I now pushed the man-pages out.
They're available here:

http://cgit.freedesktop.org/~dvdhrm/man-pages/log/?h=memfd

Thanks!
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
