Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id B99506B0036
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 20:36:06 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up7so3530199pbc.40
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 17:36:06 -0700 (PDT)
Received: from psmtp.com ([74.125.245.202])
        by mx.google.com with SMTP id it5si3229651pbc.65.2013.10.31.17.36.05
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 17:36:05 -0700 (PDT)
Message-ID: <5272F766.8000804@oracle.com>
Date: Fri, 01 Nov 2013 08:35:50 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: zram/zsmalloc issues in very low memory conditions
References: <526844E6.1080307@codeaurora.org> <52686FF4.5000303@oracle.com> <5269BCCC.6090509@codeaurora.org> <CAA25o9R_jAZyGFU3xYVjsxCCiBwiEC4gRw+JX6WG9X7G-E3LNw@mail.gmail.com> <5272E8EB.5030900@codeaurora.org>
In-Reply-To: <5272E8EB.5030900@codeaurora.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olav Haugan <ohaugan@codeaurora.org>
Cc: Luigi Semenzato <semenzato@google.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Olav,

On 11/01/2013 07:34 AM, Olav Haugan wrote:
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

AFAIK, currently zswap can't be used without a backing storage.
Perhaps you can take a try by creating a swap device backed by a file on
storage.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
