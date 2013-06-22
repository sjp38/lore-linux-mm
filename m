Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 57FB16B0034
	for <linux-mm@kvack.org>; Sat, 22 Jun 2013 13:30:31 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id c13so7379831vea.21
        for <linux-mm@kvack.org>; Sat, 22 Jun 2013 10:30:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130622103158.GA16304@infradead.org>
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
	<20130622103158.GA16304@infradead.org>
Date: Sat, 22 Jun 2013 10:30:30 -0700
Message-ID: <CAMbhsRTz246dWPQOburNor2HvrgbN-AWb2jT_AEywtJHFbKWsA@mail.gmail.com>
Subject: Re: RFC: named anonymous vmas
From: Colin Cross <ccross@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Android Kernel Team <kernel-team@android.com>, John Stultz <john.stultz@linaro.org>

On Sat, Jun 22, 2013 at 3:31 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, Jun 21, 2013 at 04:42:41PM -0700, Colin Cross wrote:
>> ranges, which John Stultz has been implementing.  The second is
>> anonymous shareable memory without having a world-writable tmpfs that
>> untrusted apps could fill with files.
>
> I still haven't seen any explanation of what ashmem buys over a shared
> mmap of /dev/zero in that respect, btw.

I believe the difference is that ashmem ties the memory to an fd, so
it can be passed to another process and mmaped to get to the same
memory, but /dev/zero does not.  Passing a /dev/zero fd and mmaping it
would result in a brand new region of zeroed memory.  Opening a tmpfs
file would allow sharing memory by passing the fd, but we don't want a
world-writable tmpfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
