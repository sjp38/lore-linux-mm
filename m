Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 68EBF6B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 05:32:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u9so24820858wme.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:32:09 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id u48si25934527wrb.323.2017.03.06.02.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 02:32:08 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id z63so10749653wmg.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:32:08 -0800 (PST)
Date: Mon, 6 Mar 2017 11:32:04 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC PATCH 10/12] staging: android: ion: Use CMA APIs directly
Message-ID: <20170306103204.d3yf6woxpsqvdakp@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1488491084-17252-11-git-send-email-labbott@redhat.com>
 <2140021.hmlAgxcLbU@avalon>
 <0541f57b-4060-ea10-7173-26ae77777518@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0541f57b-4060-ea10-7173-26ae77777518@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, dri-devel@lists.freedesktop.org, Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Fri, Mar 03, 2017 at 10:50:20AM -0800, Laura Abbott wrote:
> On 03/03/2017 08:41 AM, Laurent Pinchart wrote:
> > Hi Laura,
> > 
> > Thank you for the patch.
> > 
> > On Thursday 02 Mar 2017 13:44:42 Laura Abbott wrote:
> >> When CMA was first introduced, its primary use was for DMA allocation
> >> and the only way to get CMA memory was to call dma_alloc_coherent. This
> >> put Ion in an awkward position since there was no device structure
> >> readily available and setting one up messed up the coherency model.
> >> These days, CMA can be allocated directly from the APIs. Switch to using
> >> this model to avoid needing a dummy device. This also avoids awkward
> >> caching questions.
> > 
> > If the DMA mapping API isn't suitable for today's requirements anymore, I 
> > believe that's what needs to be fixed, instead of working around the problem 
> > by introducing another use-case-specific API.
> > 
> 
> I don't think this is a usecase specific API. CMA has been decoupled from
> DMA already because it's used in other places. The trying to go through
> DMA was just another layer of abstraction, especially since there isn't
> a device available for allocation.

Also, we've had separation of allocation and dma-mapping since forever,
that's how it works almost everywhere. Not exactly sure why/how arm-soc
ecosystem ended up focused so much on dma_alloc_coherent.

I think separating allocation from dma mapping/coherency is perfectly
fine, and the way to go.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
