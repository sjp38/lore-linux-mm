Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4152A6B038C
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 14:14:52 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id a189so150899510qkc.4
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 11:14:52 -0800 (PST)
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com. [209.85.220.171])
        by mx.google.com with ESMTPS id 124si9990712qkh.292.2017.03.03.11.14.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 11:14:51 -0800 (PST)
Received: by mail-qk0-f171.google.com with SMTP id n127so192007891qkf.0
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 11:14:51 -0800 (PST)
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1836110.VXJcCJDUAn@avalon>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <a7cfd3c5-435f-3fba-33d8-69330768eb5c@redhat.com>
Date: Fri, 3 Mar 2017 11:14:47 -0800
MIME-Version: 1.0
In-Reply-To: <1836110.VXJcCJDUAn@avalon>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, dri-devel@lists.freedesktop.org
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On 03/03/2017 08:25 AM, Laurent Pinchart wrote:
> Hi Laura,
> 
> Thank you for the patches.
> 
> On Thursday 02 Mar 2017 13:44:32 Laura Abbott wrote:
>> Hi,
>>
>> There's been some recent discussions[1] about Ion-like frameworks. There's
>> apparently interest in just keeping Ion since it works reasonablly well.
>> This series does what should be the final clean ups for it to possibly be
>> moved out of staging.
>>
>> This includes the following:
>> - Some general clean up and removal of features that never got a lot of use
>>   as far as I can tell.
>> - Fixing up the caching. This is the series I proposed back in December[2]
>>   but never heard any feedback on. It will certainly break existing
>>   applications that rely on the implicit caching. I'd rather make an effort
>>   to move to a model that isn't going directly against the establishement
>>   though.
>> - Fixing up the platform support. The devicetree approach was never well
>>   recieved by DT maintainers. The proposal here is to think of Ion less as
>>   specifying requirements and more of a framework for exposing memory to
>>   userspace.
> 
> That's where most of my concerns with ion are. I still strongly believe that 
> the heap-based approach is inherently flawed, as it would need to be 
> configured for each device according to product-specific use cases. That's not 
> something that could be easily shipped with a generic distribution. We should 
> replace that with a constraint-based system.
> 

I don't think of constraints and heaps as being mutually exclusive. Some general
heaps (e.g. system heaps) can be available always. Others might just be
exposed if there is a particular memory region available. The constraint solving
is responsible for querying and figuring out what's the best choice.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
