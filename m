Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5D46B0317
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 03:23:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m68so8304295wmg.4
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 00:23:49 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 12si3043190wrt.64.2017.04.26.00.23.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 00:23:47 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id y10so19768365wmh.0
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 00:23:47 -0700 (PDT)
Subject: Re: [PATCH 0/5] {ioctl_}userfaultfd.2: initial updates for 4.11
References: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <428a9209-e712-7067-ab11-9c35cddcd89e@gmail.com>
Date: Wed, 26 Apr 2017 09:23:45 +0200
MIME-Version: 1.0
In-Reply-To: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

Hello Mike,

On 04/25/2017 06:29 PM, Mike Rapoport wrote:
> Hello Michael,
> 
> These patches are some kind of brief highlights of the changes to the
> userfaultfd pages.

Thanks for the patches. All merged. A few tweaks made,
and pushed to Git.

> The changes to userfaultfd functionality are also described at update to
> Documentation/vm/userfaultfd.txt [1].
> 
> In general, there were three major additions:
> * hugetlbfs support
> * shmem support
> * non-page fault events
> 
> I think we should add some details about using userfaultfd with different
> memory types, describe meaning of each feature bits and add some text about
> the new events.

Agreed.

> I haven't updated 'struct uffd_msg' yet, and I hesitate whether it's
> description belongs to userfaultfd.2 or ioctl_userfaultfd.2

My guess is userfaultfd.2. But, maybe I missed something.
What suggests to you that it could be ioctl_userfaultfd.2 instead?

> As for the userfaultfd.7 we've discussed earlier, I believe it would
> repeat Documentation/vm/userfaultfd.txt in way, so I'm not really sure it
> is required.

The thing about kernel Doc files is they are a lot less visible.
It would be best I think to have the user-space visible
API fully described in man pages...

Cheers,

Michael


> [1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=5a02026d390ea1bb0c16a0e214e45613a3e3d885
> 
> Mike Rapoport (5):
>   userfaultfd.2: describe memory types that can be used from 4.11
>   ioctl_userfaultfd.2: describe memory types that can be used from 4.11
>   ioctl_userfaultfd.2: update UFFDIO_API description
>   userfaultfd.2: add Linux container migration use-case to NOTES
>   usefaultfd.2: add brief description of "non-cooperative" mode
> 
>  man2/ioctl_userfaultfd.2 | 46 ++++++++++++++++++++++++++++++++++++++--------
>  man2/userfaultfd.2       | 25 ++++++++++++++++++++++---
>  2 files changed, 60 insertions(+), 11 deletions(-)
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
