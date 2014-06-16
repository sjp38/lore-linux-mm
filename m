Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA296B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 00:36:37 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so3343405wib.5
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 21:36:36 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id o19si6898644wie.29.2014.06.15.21.36.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Jun 2014 21:36:35 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so5026514wgh.30
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 21:36:35 -0700 (PDT)
Message-ID: <539E6E93.6070102@gmail.com>
Date: Mon, 16 Jun 2014 06:12:03 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 3/7] shm: add memfd_create() syscall
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>	<1402655819-14325-4-git-send-email-dh.herrmann@gmail.com>	<CAKgNAkgnnWjrbE+2KAETsmiyrnrMQu0h7-MrYLvkiwj--_nxcQ@mail.gmail.com>	<CANq1E4R2K+eq9AxtFewp4YUL2cujg+dg+sN19Anvf-zWuvgyWw@mail.gmail.com>	<CAKgNAkgMA39AfoSoA5Pe1r9N+ZzfYQNvNPvcRN7tOvRb8+v06Q@mail.gmail.com> <CALAqxLUDDYhDbU-fa50ZHVe+yOmv0m3aOO3WmGpRrk-cPzsMAg@mail.gmail.com>
In-Reply-To: <CALAqxLUDDYhDbU-fa50ZHVe+yOmv0m3aOO3WmGpRrk-cPzsMAg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: mtk.manpages@gmail.com, David Herrmann <dh.herrmann@gmail.com>, lkml <linux-kernel@vger.kernel.org>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

On 06/13/2014 06:20 PM, John Stultz wrote:
> On Fri, Jun 13, 2014 at 7:20 AM, Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>>
>> The general notion these days is that a (comprehensive) manual page
>> _should_ come *with* the system call, rather than after the fact. And
>> there's a lot of value in that. I've found no end of bugs and design
>> errors while writing (comprehensive) man pages after the fact (by
>> which time it's too late to fix the design errors), and also found
>> quite a few of those issues when I've managed to work with folk at the
>> same time as they write the syscall. Bottom line: you really should
>> write formal documentation now, as part of the process of code
>> submission. It improves the chance of finding implementation and
>> design bugs, and may well widen your circle of reviewers.
> 
> I very much agree here. One practical issue I've noticed is that
> having separate targets for both the code changes and the manpages can
> be an extra barrier for folks getting changes correctly documented as
> the change is being submitted. Reviewers may say "be sure to send
> updates to the man pages" but its not always easy to remember to
> follow up and make sure the submitter got the changes (which match the
> merged patches) to you as well.
> 
> I've been thinking it might be nice to have the kernel syscall man
> pages included in the kernel source tree, then have them
> copied/imported over to the man-pages project (similar to how glibc
> imports uapi kernel headers).  They could even be kept in the
> include/uapi directory, and checkpatch could ensure that changes that
> touch include/uapi also have modifications to something in the
> manpages directory. This way folks would be able to include the man
> page change with the code change, making it easier for developers to
> do the right thing, making it easier for reviewers to ensure its
> correct, and making it easier for maintainers to ensure man page
> documentation is properly in sync.
> 
> Or is this something that has been hashed over already? I do admit
> this would disrupt your process a bit.

It's more a less a FAQ from my point of view, so I wrote this:
https://www.kernel.org/doc/man-pages/todo.html#migrate_to_kernel_source

In short, I agree that the current process is not optimal, but lacking
(a lot) more time, it'd be hard to make any change to the current 
process. In any case, I think there's room for a lot of improvement
even without changing the current process. (For example, while I 
agree that having man pages in a separate location from the kernel 
source does create some barriers, I don't think it's the reason
most developers don't update the man pages. One just has to
look at the patchy state Documentation/filesystems/proc.txt as one 
example to support that view point.)

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
