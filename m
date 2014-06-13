Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 792146B00BD
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:41:25 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so1493878igd.3
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 05:41:25 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id ce6si6623476icc.61.2014.06.13.05.41.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 05:41:24 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id rd18so2434695iec.35
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 05:41:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKgNAkgnnWjrbE+2KAETsmiyrnrMQu0h7-MrYLvkiwj--_nxcQ@mail.gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<1402655819-14325-4-git-send-email-dh.herrmann@gmail.com>
	<CAKgNAkgnnWjrbE+2KAETsmiyrnrMQu0h7-MrYLvkiwj--_nxcQ@mail.gmail.com>
Date: Fri, 13 Jun 2014 14:41:24 +0200
Message-ID: <CANq1E4R2K+eq9AxtFewp4YUL2cujg+dg+sN19Anvf-zWuvgyWw@mail.gmail.com>
Subject: Re: [PATCH v3 3/7] shm: add memfd_create() syscall
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk-manpages <mtk.manpages@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

Hi

On Fri, Jun 13, 2014 at 2:27 PM, Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> Hi David,
>
> On Fri, Jun 13, 2014 at 12:36 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
>> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
>> that you can pass to mmap(). It can support sealing and avoids any
>> connection to user-visible mount-points. Thus, it's not subject to quotas
>> on mounted file-systems, but can be used like malloc()'ed memory, but
>> with a file-descriptor to it.
>>
>> memfd_create() returns the raw shmem file, so calls like ftruncate() can
>> be used to modify the underlying inode. Also calls like fstat()
>> will return proper information and mark the file as regular file. If you
>> want sealing, you can specify MFD_ALLOW_SEALING. Otherwise, sealing is not
>> supported (like on all other regular files).
>>
>> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
>> subject to quotas and alike. It is still properly accounted to memcg
>> limits, though.
>
> Where do I find / is there detailed documentation (ideally, a man
> page) for this new system call?

I did write a man-page proposal for memfd_create() and a patch for
fcntl() for v1, however, the API changed several times so I didn't
keep them up to date (the man-page patches are on LKML). However, I
wrote a short introduction to memfd+sealing v3, that I recommend
reading first:
  http://dvdhrm.wordpress.com/2014/06/10/memfd_create2/

This explains the idea behind the new API and describes almost all
aspects of it. It's up-to-date to v3 and I will use it to write the
final man-pages once Hugh and Andrew ACKed the patches. Let me know if
anything is unclear.

Thanks for looking at it!
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
