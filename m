Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D680D6B0035
	for <linux-mm@kvack.org>; Sat,  2 Nov 2013 03:40:51 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so4730230pdj.24
        for <linux-mm@kvack.org>; Sat, 02 Nov 2013 00:40:51 -0700 (PDT)
Received: from psmtp.com ([74.125.245.166])
        by mx.google.com with SMTP id j10si6593557pac.170.2013.11.02.00.40.50
        for <linux-mm@kvack.org>;
        Sat, 02 Nov 2013 00:40:50 -0700 (PDT)
Received: from smtp.stanford.edu (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 1ED8622663
	for <linux-mm@kvack.org>; Sat,  2 Nov 2013 00:40:49 -0700 (PDT)
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	(using TLSv1 with cipher ECDHE-RSA-RC4-SHA (128/128 bits))
	(No client certificate requested)
	by smtp.stanford.edu (Postfix) with ESMTPS id BFC4A2260D
	for <linux-mm@kvack.org>; Sat,  2 Nov 2013 00:40:48 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so4963375pab.22
        for <linux-mm@kvack.org>; Sat, 02 Nov 2013 00:40:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9RwKbjDo5knY9ZFvmVFKDCwE2Gu3fmz2GwMFjBO2f-V=Q@mail.gmail.com>
References: <526844E6.1080307@codeaurora.org>
	<52686FF4.5000303@oracle.com>
	<5269BCCC.6090509@codeaurora.org>
	<CAA25o9R_jAZyGFU3xYVjsxCCiBwiEC4gRw+JX6WG9X7G-E3LNw@mail.gmail.com>
	<5272E8EB.5030900@codeaurora.org>
	<CAA25o9RwKbjDo5knY9ZFvmVFKDCwE2Gu3fmz2GwMFjBO2f-V=Q@mail.gmail.com>
Date: Sat, 2 Nov 2013 00:40:48 -0700
Message-ID: <CA+DLN_AH9PVkywCpKWHJ1568O0MsjwZZw2zXuPn55msodO0m5w@mail.gmail.com>
Subject: Re: zram/zsmalloc issues in very low memory conditions
From: Stephen Barber <smbarber@stanford.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Olav Haugan <ohaugan@codeaurora.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

I did get zswap working without a backing store, using Bob's patches
from http://thread.gmane.org/gmane.linux.kernel.mm/105627/focus=105642
applied to 3.11-rc6, The major issue we had with it was that i915
graphics buffers were getting corrupted somehow, which wasn't a
problem with zram on the same kernel version. I'm sure with a little
more investigation that problem could be fixed, though, and I don't
think there were any other major problems with it in our (admittedly
not very exhaustive) testing of those patches.

Hope that helps,
Steve Barber

On Thu, Oct 31, 2013 at 5:27 PM, Luigi Semenzato <semenzato@google.com> wrote:
> [apologies for the previous HTML email]
>
> Hi Olav,
>
> I haven't personally done it.  Seth outlines the configuration in this thread:
>
> http://thread.gmane.org/gmane.linux.kernel.mm/105378/focus=105543
>
> Stephen, can you add more detail from your experience?
>
> Thanks!
>
>
> On Thu, Oct 31, 2013 at 4:34 PM, Olav Haugan <ohaugan@codeaurora.org> wrote:
>> Hi Luigi,
>>
>> On 10/24/2013 6:12 PM, Luigi Semenzato wrote:
>>> On Thu, Oct 24, 2013 at 5:35 PM, Olav Haugan <ohaugan@codeaurora.org> wrote:
>>>> Hi Bob, Luigi,
>>>>
>>>> On 10/23/2013 5:55 PM, Bob Liu wrote:
>>>>>
>>>>> On 10/24/2013 05:51 AM, Olav Haugan wrote:
>>>>
>>>>> By the way, could you take a try with zswap? Which can write pages to
>>>>> real swap device if compressed pool is full.
>>>>
>>>> zswap might not be feasible in all cases if you only have flash as
>>>> backing storage.
>>>
>>> Zswap can be configured to run without a backing storage.
>>>
>>
>> I was under the impression that zswap requires a backing storage. Can
>> you elaborate on how to configure zswap to not need a backing storage?
>>
>>
>> Olav Haugan
>>
>> --
>> The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
>> hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
