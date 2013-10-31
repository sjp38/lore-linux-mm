Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0F30E6B0036
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 19:34:07 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so3074245pdj.11
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 16:34:07 -0700 (PDT)
Received: from psmtp.com ([74.125.245.190])
        by mx.google.com with SMTP id gu5si3430184pac.217.2013.10.31.16.34.06
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 16:34:07 -0700 (PDT)
Message-ID: <5272E8EB.5030900@codeaurora.org>
Date: Thu, 31 Oct 2013 16:34:03 -0700
From: Olav Haugan <ohaugan@codeaurora.org>
MIME-Version: 1.0
Subject: Re: zram/zsmalloc issues in very low memory conditions
References: <526844E6.1080307@codeaurora.org> <52686FF4.5000303@oracle.com> <5269BCCC.6090509@codeaurora.org> <CAA25o9R_jAZyGFU3xYVjsxCCiBwiEC4gRw+JX6WG9X7G-E3LNw@mail.gmail.com>
In-Reply-To: <CAA25o9R_jAZyGFU3xYVjsxCCiBwiEC4gRw+JX6WG9X7G-E3LNw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Luigi,

On 10/24/2013 6:12 PM, Luigi Semenzato wrote:
> On Thu, Oct 24, 2013 at 5:35 PM, Olav Haugan <ohaugan@codeaurora.org> wrote:
>> Hi Bob, Luigi,
>>
>> On 10/23/2013 5:55 PM, Bob Liu wrote:
>>>
>>> On 10/24/2013 05:51 AM, Olav Haugan wrote:
>>
>>> By the way, could you take a try with zswap? Which can write pages to
>>> real swap device if compressed pool is full.
>>
>> zswap might not be feasible in all cases if you only have flash as
>> backing storage.
> 
> Zswap can be configured to run without a backing storage.
> 

I was under the impression that zswap requires a backing storage. Can
you elaborate on how to configure zswap to not need a backing storage?


Olav Haugan

-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
