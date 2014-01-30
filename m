Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2026B0036
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 11:03:02 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id e9so5320860qcy.29
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 08:03:02 -0800 (PST)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id t1si2137919qch.86.2014.01.30.08.03.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 08:03:01 -0800 (PST)
Received: by mail-qc0-f171.google.com with SMTP id n7so5173798qcx.16
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 08:03:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140130084657.GA31508@infradead.org>
References: <52E709C0.1050006@linaro.org> <20140130084657.GA31508@infradead.org>
From: Kay Sievers <kay@vrfy.org>
Date: Thu, 30 Jan 2014 17:02:40 +0100
Message-ID: <CAPXgP13rAYV9SEQ0jgzD2C2vwWVxgqQfD__+ooAQcoPUu-RXhQ@mail.gmail.com>
Subject: Re: [RFC] shmgetfd idea
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On Thu, Jan 30, 2014 at 9:46 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Jan 27, 2014 at 05:37:04PM -0800, John Stultz wrote:
>> In working with ashmem and looking briefly at kdbus' memfd ideas,
>> there's a commonality that both basically act as a method to provide
>> applications with unlinked tmpfs/shmem fds.
>
> Just use O_TMPFILE on a tmpfs file and you're done.

Ashmem and kdbus can name the deleted files, which is useful for
debugging and tools to show the associated name for the file
descriptor. They also show up in /proc/$PID/maps/ and possibly in
/proc/$PID/fd/.

O_TMPFILE always creates files with just the name "/". Unless that is
changed we wouldn't want switch over to O_TMPFILE, because we would
lose that nice feature.

Is there are way to "fix" O_TMPFILE to accept the name of the file to
be created, instead of insisting to take only the leading directory as
the argument?

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
