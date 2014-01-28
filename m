Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2250B6B0037
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 14:47:25 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so789646pab.15
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 11:47:24 -0800 (PST)
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
        by mx.google.com with ESMTPS id cf2si10108497pad.227.2014.01.28.11.47.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 11:47:23 -0800 (PST)
Received: by mail-pb0-f43.google.com with SMTP id md12so789278pbc.16
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 11:47:23 -0800 (PST)
Message-ID: <52E80943.3060806@linaro.org>
Date: Tue, 28 Jan 2014 11:47:15 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org> <CAPXgP10j5MVwhbkhOqx2z4SX-zAniNbZmk6jcK74Y_kMSN4SOA@mail.gmail.com>
In-Reply-To: <CAPXgP10j5MVwhbkhOqx2z4SX-zAniNbZmk6jcK74Y_kMSN4SOA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kay Sievers <kay@vrfy.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/27/2014 05:53 PM, Kay Sievers wrote:
> On Tue, Jan 28, 2014 at 2:37 AM, John Stultz <john.stultz@linaro.org> wrote:
>> Anyway, I just wanted to submit this sketched out idea as food for
>> thought to see if there was any objection or interest (I've got a draft
>> patch I'll send out once I get a chance to test it). So let me know if
>> you have any feedback or comments.
> The reason "kdbus-memfd" exists is primarily the sealing.
[snip]
> It would be nice if we can generalize the whole memfd logic, but the
> shmem allocation facility alone, without the sealing function cannot
> replace kdbus-memfd.

Yes. Quite understood. And I too hope to discuss how the sealing feature
could be generalized when the code is submitted for review. I just
figured I'd start here, so when that time comes we have a sketch for
what the rest of the parts that would be needed are.


> We would need secure sealing right from the start for the kdbus use
> case; other than that, there are no specific requirements from the
> kdbus side.

Thanks for the clarifications!

-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
