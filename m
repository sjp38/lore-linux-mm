Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 35AB36B0039
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 14:56:59 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so801803pab.17
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 11:56:58 -0800 (PST)
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
        by mx.google.com with ESMTPS id fl7si16538046pad.316.2014.01.28.11.56.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 11:56:57 -0800 (PST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so795111pbb.35
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 11:56:57 -0800 (PST)
Message-ID: <52E80B85.8020302@linaro.org>
Date: Tue, 28 Jan 2014 11:56:53 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com>
In-Reply-To: <52E7298D.5020001@zytor.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Kay Sievers <kay@vrfy.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/27/2014 07:52 PM, H. Peter Anvin wrote:
> On 01/27/2014 05:37 PM, John Stultz wrote:
>> In the Android case, its important to have this interface to atomically
>> provide these unlinked tmpfs fds, because they'd like to avoid having
>> tmpfs mounts that are writable by applications (since that creates a
>> potential DOS on the system by applications writing random files that
>> persist after the process has been killed). It also provides better
>> life-cycle management for resources, since as the fds never have named
>> links in the filesystem, their resources are automatically cleaned up
>> when the last process with the fd dies, and there's no potential races
>> between create and unlink with processes being terminated, which avoids
>> the need for cleanup management.
>>
> What about if tmpfs could be restricted to only only O_TMPFILE open()s?
>  This pretty much amounts to an option to prevent tmpfs from creating
> new directory entries.

Thanks for reminding me about O_TMPFILE.. I have it on my list to look
into how it could be used.

As for the O_TMPFILE only tmpfs option, it seems maybe a little clunky
to me, but possible. If others think this would be preferred over a new
syscall, I'll dig in deeper.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
