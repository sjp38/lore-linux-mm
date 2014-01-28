Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7301E6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 18:14:20 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id p10so956206pdj.29
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:14:20 -0800 (PST)
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
        by mx.google.com with ESMTPS id tq5si190078pac.182.2014.01.28.15.14.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 15:14:18 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id x10so956836pdj.11
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:14:18 -0800 (PST)
Message-ID: <52E839C6.9040509@linaro.org>
Date: Tue, 28 Jan 2014 15:14:14 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com> <52E80B85.8020302@linaro.org> <52E814FF.6060403@zytor.com> <52E819F0.6040806@linaro.org> <CAPXgP11Fv6TU+o2Eui5rVW0A37U7KjwC0DZYbQOJJ8rEAYOiJg@mail.gmail.com> <52E81BB3.6060306@linaro.org> <52E81CE2.3030304@zytor.com> <52E8271B.4030201@linaro.org> <CAPXgP13G14B3YFpaE+m_AtFfFR6NRVSi1JYAvLZSsfftSkgwBQ@mail.gmail.com>
In-Reply-To: <CAPXgP13G14B3YFpaE+m_AtFfFR6NRVSi1JYAvLZSsfftSkgwBQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kay Sievers <kay@vrfy.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/28/2014 02:14 PM, Kay Sievers wrote:
> On Tue, Jan 28, 2014 at 10:54 PM, John Stultz <john.stultz@linaro.org> wrote:
>> But yes, alternatively classic systems may be able to get around the
>> issues via tmpfs quotas and convincing applications to use O_TMPFILE
>> there. But to me this seems less ideal then the Android approach, where
>> the lifecycle of the tmpfs fds more limited and clear.
> Tmpfs supports no quota, it's all a huge hole and unsafe in that
> regard on every system today. But ashmem and kdbus, as they are today,
> are not better.

While its true ashmem and kdbus currently have no limitation on the
amount of memory an application can consume via the unlinked tmpfs fds,
they both do have the benefit that those unlinked files are cleaned up
when the last user dies (or is killed).

While adding quota to these approaches would improve things, tmpfs quota
alone on writable tmpfs mounts only limits the DOS to the user (ie: one
bad application could fill up the user's tmpfs and quit, then other
applications would fail to work or have some sort of logic to figure out
what tmpfs files could safely be cleaned up).

Other then this minor point, I think I'm in agreement with the other
points in your mail.

thanks
-john




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
