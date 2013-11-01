Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 250346B0036
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 20:27:19 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so3264851pad.41
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 17:27:18 -0700 (PDT)
Received: from psmtp.com ([74.125.245.204])
        by mx.google.com with SMTP id cj2si3180332pbc.297.2013.10.31.17.27.17
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 17:27:18 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id as1so6382900iec.27
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 17:27:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5272E8EB.5030900@codeaurora.org>
References: <526844E6.1080307@codeaurora.org>
	<52686FF4.5000303@oracle.com>
	<5269BCCC.6090509@codeaurora.org>
	<CAA25o9R_jAZyGFU3xYVjsxCCiBwiEC4gRw+JX6WG9X7G-E3LNw@mail.gmail.com>
	<5272E8EB.5030900@codeaurora.org>
Date: Thu, 31 Oct 2013 17:27:16 -0700
Message-ID: <CAA25o9RwKbjDo5knY9ZFvmVFKDCwE2Gu3fmz2GwMFjBO2f-V=Q@mail.gmail.com>
Subject: Re: zram/zsmalloc issues in very low memory conditions
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olav Haugan <ohaugan@codeaurora.org>, Stephen Barber <smbarber@stanford.edu>
Cc: Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

[apologies for the previous HTML email]

Hi Olav,

I haven't personally done it.  Seth outlines the configuration in this thread:

http://thread.gmane.org/gmane.linux.kernel.mm/105378/focus=105543

Stephen, can you add more detail from your experience?

Thanks!


On Thu, Oct 31, 2013 at 4:34 PM, Olav Haugan <ohaugan@codeaurora.org> wrote:
> Hi Luigi,
>
> On 10/24/2013 6:12 PM, Luigi Semenzato wrote:
>> On Thu, Oct 24, 2013 at 5:35 PM, Olav Haugan <ohaugan@codeaurora.org> wrote:
>>> Hi Bob, Luigi,
>>>
>>> On 10/23/2013 5:55 PM, Bob Liu wrote:
>>>>
>>>> On 10/24/2013 05:51 AM, Olav Haugan wrote:
>>>
>>>> By the way, could you take a try with zswap? Which can write pages to
>>>> real swap device if compressed pool is full.
>>>
>>> zswap might not be feasible in all cases if you only have flash as
>>> backing storage.
>>
>> Zswap can be configured to run without a backing storage.
>>
>
> I was under the impression that zswap requires a backing storage. Can
> you elaborate on how to configure zswap to not need a backing storage?
>
>
> Olav Haugan
>
> --
> The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
> hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
