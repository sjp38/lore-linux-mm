Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4B57B6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 18:03:19 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id l18so2126691wgh.5
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:03:18 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id s9si78113wjf.70.2014.01.28.15.03.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jan 2014 15:03:18 -0800 (PST)
Message-ID: <52E83719.9060709@zytor.com>
Date: Tue, 28 Jan 2014 15:02:49 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com> <52E80B85.8020302@linaro.org> <52E814FF.6060403@zytor.com> <52E819F0.6040806@linaro.org> <CAPXgP11Fv6TU+o2Eui5rVW0A37U7KjwC0DZYbQOJJ8rEAYOiJg@mail.gmail.com> <52E81BB3.6060306@linaro.org> <52E81CE2.3030304@zytor.com> <52E8271B.4030201@linaro.org> <CAPXgP13G14B3YFpaE+m_AtFfFR6NRVSi1JYAvLZSsfftSkgwBQ@mail.gmail.com>
In-Reply-To: <CAPXgP13G14B3YFpaE+m_AtFfFR6NRVSi1JYAvLZSsfftSkgwBQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kay Sievers <kay@vrfy.org>, John Stultz <john.stultz@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/28/2014 02:14 PM, Kay Sievers wrote:
>>
>> But yes, alternatively classic systems may be able to get around the
>> issues via tmpfs quotas and convincing applications to use O_TMPFILE
>> there. But to me this seems less ideal then the Android approach, where
>> the lifecycle of the tmpfs fds more limited and clear.
> 
> Tmpfs supports no quota, it's all a huge hole and unsafe in that
> regard on every system today. But ashmem and kdbus, as they are today,
> are not better.
> 

We can fix that aspect in tmpfs.  Creating new file objcts outside of
filesystems really doesn't make things any better, since our toolbox
around this stuff largely revolves around filesystems.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
