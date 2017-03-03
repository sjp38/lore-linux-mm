Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C021A6B038C
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 13:50:25 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id v125so4749362qkh.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 10:50:25 -0800 (PST)
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com. [209.85.220.173])
        by mx.google.com with ESMTPS id 94si9973518qte.172.2017.03.03.10.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 10:50:25 -0800 (PST)
Received: by mail-qk0-f173.google.com with SMTP id 1so71600092qkl.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 10:50:25 -0800 (PST)
Subject: Re: [RFC PATCH 10/12] staging: android: ion: Use CMA APIs directly
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1488491084-17252-11-git-send-email-labbott@redhat.com>
 <2140021.hmlAgxcLbU@avalon>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <0541f57b-4060-ea10-7173-26ae77777518@redhat.com>
Date: Fri, 3 Mar 2017 10:50:20 -0800
MIME-Version: 1.0
In-Reply-To: <2140021.hmlAgxcLbU@avalon>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, dri-devel@lists.freedesktop.org
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On 03/03/2017 08:41 AM, Laurent Pinchart wrote:
> Hi Laura,
> 
> Thank you for the patch.
> 
> On Thursday 02 Mar 2017 13:44:42 Laura Abbott wrote:
>> When CMA was first introduced, its primary use was for DMA allocation
>> and the only way to get CMA memory was to call dma_alloc_coherent. This
>> put Ion in an awkward position since there was no device structure
>> readily available and setting one up messed up the coherency model.
>> These days, CMA can be allocated directly from the APIs. Switch to using
>> this model to avoid needing a dummy device. This also avoids awkward
>> caching questions.
> 
> If the DMA mapping API isn't suitable for today's requirements anymore, I 
> believe that's what needs to be fixed, instead of working around the problem 
> by introducing another use-case-specific API.
> 

I don't think this is a usecase specific API. CMA has been decoupled from
DMA already because it's used in other places. The trying to go through
DMA was just another layer of abstraction, especially since there isn't
a device available for allocation.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
