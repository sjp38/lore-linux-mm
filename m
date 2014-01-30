Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDB76B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:42:50 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so3509086pdj.36
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:42:50 -0800 (PST)
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
        by mx.google.com with ESMTPS id ek3si7963722pbd.115.2014.01.30.13.42.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 13:42:49 -0800 (PST)
Received: by mail-pd0-f177.google.com with SMTP id x10so3480187pdj.8
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:42:49 -0800 (PST)
Message-ID: <52EAC755.5080408@linaro.org>
Date: Thu, 30 Jan 2014 13:42:45 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org> <20140130084657.GA31508@infradead.org> <CAPXgP13rAYV9SEQ0jgzD2C2vwWVxgqQfD__+ooAQcoPUu-RXhQ@mail.gmail.com>
In-Reply-To: <CAPXgP13rAYV9SEQ0jgzD2C2vwWVxgqQfD__+ooAQcoPUu-RXhQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kay Sievers <kay@vrfy.org>, Christoph Hellwig <hch@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/30/2014 08:02 AM, Kay Sievers wrote:
> On Thu, Jan 30, 2014 at 9:46 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> On Mon, Jan 27, 2014 at 05:37:04PM -0800, John Stultz wrote:
>>> In working with ashmem and looking briefly at kdbus' memfd ideas,
>>> there's a commonality that both basically act as a method to provide
>>> applications with unlinked tmpfs/shmem fds.
>> Just use O_TMPFILE on a tmpfs file and you're done.
> Ashmem and kdbus can name the deleted files, which is useful for
> debugging and tools to show the associated name for the file
> descriptor. They also show up in /proc/$PID/maps/ and possibly in
> /proc/$PID/fd/.
>
> O_TMPFILE always creates files with just the name "/". Unless that is
> changed we wouldn't want switch over to O_TMPFILE, because we would
> lose that nice feature.

Not sure, but would Colin's vma-naming patch (or something like it) help
address this?
https://lkml.org/lkml/2013/10/30/518

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
