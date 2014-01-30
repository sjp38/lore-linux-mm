Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9036B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 03:47:04 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id o15so3947317qap.16
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 00:47:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id fy9si3862759qab.21.2014.01.30.00.47.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jan 2014 00:47:01 -0800 (PST)
Date: Thu, 30 Jan 2014 00:46:57 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] shmgetfd idea
Message-ID: <20140130084657.GA31508@infradead.org>
References: <52E709C0.1050006@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52E709C0.1050006@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Kay Sievers <kay@vrfy.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On Mon, Jan 27, 2014 at 05:37:04PM -0800, John Stultz wrote:
> In working with ashmem and looking briefly at kdbus' memfd ideas,
> there's a commonality that both basically act as a method to provide
> applications with unlinked tmpfs/shmem fds.

Just use O_TMPFILE on a tmpfs file and you're done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
