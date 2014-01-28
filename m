Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id C1F126B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 22:53:14 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id d7so85445bkh.20
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 19:53:14 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id q2si16216861bkr.259.2014.01.27.19.53.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jan 2014 19:53:13 -0800 (PST)
Message-ID: <52E7298D.5020001@zytor.com>
Date: Mon, 27 Jan 2014 19:52:45 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org>
In-Reply-To: <52E709C0.1050006@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Kay Sievers <kay@vrfy.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/27/2014 05:37 PM, John Stultz wrote:
> 
> In the Android case, its important to have this interface to atomically
> provide these unlinked tmpfs fds, because they'd like to avoid having
> tmpfs mounts that are writable by applications (since that creates a
> potential DOS on the system by applications writing random files that
> persist after the process has been killed). It also provides better
> life-cycle management for resources, since as the fds never have named
> links in the filesystem, their resources are automatically cleaned up
> when the last process with the fd dies, and there's no potential races
> between create and unlink with processes being terminated, which avoids
> the need for cleanup management.
> 

What about if tmpfs could be restricted to only only O_TMPFILE open()s?
 This pretty much amounts to an option to prevent tmpfs from creating
new directory entries.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
