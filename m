Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 595D76B0037
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:37:53 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so1837977wgh.7
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 12:37:52 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id s4si8493130wjq.83.2014.01.28.12.37.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jan 2014 12:37:52 -0800 (PST)
Message-ID: <52E814FF.6060403@zytor.com>
Date: Tue, 28 Jan 2014 12:37:19 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com> <52E80B85.8020302@linaro.org>
In-Reply-To: <52E80B85.8020302@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Kay Sievers <kay@vrfy.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/28/2014 11:56 AM, John Stultz wrote:
> 
> Thanks for reminding me about O_TMPFILE.. I have it on my list to look
> into how it could be used.
> 
> As for the O_TMPFILE only tmpfs option, it seems maybe a little clunky
> to me, but possible. If others think this would be preferred over a new
> syscall, I'll dig in deeper.
> 

What is clunky about it?  It reuses an existing interface and still
points to the specific tmpfs instance that should be populated.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
