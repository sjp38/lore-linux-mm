Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id B1C7C6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:58:29 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so860196pbb.6
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 12:58:29 -0800 (PST)
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
        by mx.google.com with ESMTPS id xu6si16762949pab.196.2014.01.28.12.58.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 12:58:28 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id z10so830223pdj.33
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 12:58:27 -0800 (PST)
Message-ID: <52E819F0.6040806@linaro.org>
Date: Tue, 28 Jan 2014 12:58:24 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com> <52E80B85.8020302@linaro.org> <52E814FF.6060403@zytor.com>
In-Reply-To: <52E814FF.6060403@zytor.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Kay Sievers <kay@vrfy.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/28/2014 12:37 PM, H. Peter Anvin wrote:
> On 01/28/2014 11:56 AM, John Stultz wrote:
>> Thanks for reminding me about O_TMPFILE.. I have it on my list to look
>> into how it could be used.
>>
>> As for the O_TMPFILE only tmpfs option, it seems maybe a little clunky
>> to me, but possible. If others think this would be preferred over a new
>> syscall, I'll dig in deeper.
>>
> What is clunky about it?  It reuses an existing interface and still
> points to the specific tmpfs instance that should be populated.

It would require new mount point convention that userland would have to
standardize.  To me (and admittedly its a taste thing), a new
O_TMPFILE-only tmpfs mount point seems to be to be a bigger interface
change from an application writers perspective then a new syscall.

But maybe I'm misunderstanding your suggestion?

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
