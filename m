Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA196B0039
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 19:01:48 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id o15so5377500qap.2
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:01:47 -0800 (PST)
Received: from mail-qc0-x22e.google.com (mail-qc0-x22e.google.com [2607:f8b0:400d:c01::22e])
        by mx.google.com with ESMTPS id s22si5934225qge.116.2014.01.30.16.01.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 16:01:47 -0800 (PST)
Received: by mail-qc0-f174.google.com with SMTP id x13so5987636qcv.19
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:01:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52EAC755.5080408@linaro.org>
References: <52E709C0.1050006@linaro.org> <20140130084657.GA31508@infradead.org>
 <CAPXgP13rAYV9SEQ0jgzD2C2vwWVxgqQfD__+ooAQcoPUu-RXhQ@mail.gmail.com> <52EAC755.5080408@linaro.org>
From: Kay Sievers <kay@vrfy.org>
Date: Fri, 31 Jan 2014 01:01:27 +0100
Message-ID: <CAPXgP13D+rrW0W_DtyGdwS35XsXrAyHqRqh1km4UJg8URtNMyQ@mail.gmail.com>
Subject: Re: [RFC] shmgetfd idea
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On Thu, Jan 30, 2014 at 10:42 PM, John Stultz <john.stultz@linaro.org> wrote:
> On 01/30/2014 08:02 AM, Kay Sievers wrote:
>> On Thu, Jan 30, 2014 at 9:46 AM, Christoph Hellwig <hch@infradead.org> wrote:
>>> On Mon, Jan 27, 2014 at 05:37:04PM -0800, John Stultz wrote:
>>>> In working with ashmem and looking briefly at kdbus' memfd ideas,
>>>> there's a commonality that both basically act as a method to provide
>>>> applications with unlinked tmpfs/shmem fds.
>>> Just use O_TMPFILE on a tmpfs file and you're done.
>> Ashmem and kdbus can name the deleted files, which is useful for
>> debugging and tools to show the associated name for the file
>> descriptor. They also show up in /proc/$PID/maps/ and possibly in
>> /proc/$PID/fd/.
>>
>> O_TMPFILE always creates files with just the name "/". Unless that is
>> changed we wouldn't want switch over to O_TMPFILE, because we would
>> lose that nice feature.
>
> Not sure, but would Colin's vma-naming patch (or something like it) help
> address this?
> https://lkml.org/lkml/2013/10/30/518

Hmm, I don't think so, this seems to be about anonymous memory only,
but shmem files are not anonymous.

We actually just really want the actual file names, ashmem too, like
shmem_file_setup() accepts the name for the unlinked file to create.

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
