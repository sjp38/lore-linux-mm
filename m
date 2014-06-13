Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF816B003A
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 11:11:18 -0400 (EDT)
Received: by mail-ve0-f179.google.com with SMTP id sa20so1595218veb.24
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:11:18 -0700 (PDT)
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
        by mx.google.com with ESMTPS id ez10si1494102vdb.103.2014.06.13.08.11.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 08:11:17 -0700 (PDT)
Received: by mail-ve0-f179.google.com with SMTP id sa20so1626962veb.10
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:11:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 13 Jun 2014 08:10:57 -0700
Message-ID: <CALCETrVoE+JO2rLsBUHAOJdvescEEjxikj8iQ339Nxfopfc7pw@mail.gmail.com>
Subject: Re: [PATCH v3 0/7] File Sealing & memfd_create()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>

On Fri, Jun 13, 2014 at 3:36 AM, David Herrmann <dh.herrmann@gmail.com> wrote:
> Hi
>
> This is v3 of the File-Sealing and memfd_create() patches. You can find v1 with
> a longer introduction at gmane:
>   http://thread.gmane.org/gmane.comp.video.dri.devel/102241
> An LWN article about memfd+sealing is available, too:
>   https://lwn.net/Articles/593918/
> v2 with some more discussions can be found here:
>   http://thread.gmane.org/gmane.linux.kernel.mm/115713
>
> This series introduces two new APIs:
>   memfd_create(): Think of this syscall as malloc() but it returns a
>                   file-descriptor instead of a pointer. That file-descriptor is
>                   backed by anon-memory and can be memory-mapped for access.
>   sealing: The sealing API can be used to prevent a specific set of operations
>            on a file-descriptor. You 'seal' the file and give thus the
>            guarantee, that it cannot be modified in the specific ways.
>
> A short high-level introduction is also available here:
>   http://dvdhrm.wordpress.com/2014/06/10/memfd_create2/

Potentially silly question: is it guaranteed that mmapping and reading
a SEAL_SHRINKed fd within size bounds will not SIGBUS?  If so, should
this be documented?  (The particular issue here would be reading
holes.  It should work by using the zero page, but, if so, we should
probably make it a real documented guarantee.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
