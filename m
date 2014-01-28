Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 19B856B0039
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:06:03 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so858021pbc.41
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:06:02 -0800 (PST)
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
        by mx.google.com with ESMTPS id zk9si16842562pac.28.2014.01.28.13.05.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 13:05:59 -0800 (PST)
Received: by mail-pd0-f171.google.com with SMTP id g10so840705pdj.2
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:05:59 -0800 (PST)
Message-ID: <52E81BB3.6060306@linaro.org>
Date: Tue, 28 Jan 2014 13:05:55 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com> <52E80B85.8020302@linaro.org> <52E814FF.6060403@zytor.com> <52E819F0.6040806@linaro.org> <CAPXgP11Fv6TU+o2Eui5rVW0A37U7KjwC0DZYbQOJJ8rEAYOiJg@mail.gmail.com>
In-Reply-To: <CAPXgP11Fv6TU+o2Eui5rVW0A37U7KjwC0DZYbQOJJ8rEAYOiJg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kay Sievers <kay@vrfy.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/28/2014 01:01 PM, Kay Sievers wrote:
> On Tue, Jan 28, 2014 at 9:58 PM, John Stultz <john.stultz@linaro.org> wrote:
>> On 01/28/2014 12:37 PM, H. Peter Anvin wrote:
>>> On 01/28/2014 11:56 AM, John Stultz wrote:
>>>> Thanks for reminding me about O_TMPFILE.. I have it on my list to look
>>>> into how it could be used.
>>>>
>>>> As for the O_TMPFILE only tmpfs option, it seems maybe a little clunky
>>>> to me, but possible. If others think this would be preferred over a new
>>>> syscall, I'll dig in deeper.
>>>>
>>> What is clunky about it?  It reuses an existing interface and still
>>> points to the specific tmpfs instance that should be populated.
>> It would require new mount point convention that userland would have to
>> standardize.  To me (and admittedly its a taste thing), a new
>> O_TMPFILE-only tmpfs mount point seems to be to be a bigger interface
>> change from an application writers perspective then a new syscall.
>>
>> But maybe I'm misunderstanding your suggestion?
> General purpose Linux has /dev/shm/ for that already, which will not
> go away anytime soon..

Right, though making /dev/shm/ O_TMPFILE only would likely break things, no?

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
