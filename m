Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B03A86B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 04:48:27 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so24671889wmw.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:48:27 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id fj5si8979032wjb.227.2016.05.18.01.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 01:48:26 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so10881817wmw.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:48:26 -0700 (PDT)
Date: Wed, 18 May 2016 10:48:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: malloc() size in CMA region seems to be aligned to CMA_ALIGNMENT
Message-ID: <20160518084824.GA21680@dhcp22.suse.cz>
References: <CA+a3UFfGxJajS3Lqkp8M4kaikTWHprUXbUvECYC9dojgazQ8pg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+a3UFfGxJajS3Lqkp8M4kaikTWHprUXbUvECYC9dojgazQ8pg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lunar12 lunartwix <lunartwix@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>

[CC linux-mm and some usual suspects]

On Tue 17-05-16 23:37:55, lunar12 lunartwix wrote:
> A 4MB dma_alloc_coherent  in kernel after malloc(2*1024) 40 times in
> CMA region by user space will cause an error on our ARM 3.18 kernel
> platform with a 32MB CMA.
> 
> It seems that the malloc in CMA region will be aligned to
> CMA_ALIGNMENT everytime even if the requested malloc size is very
> small so the CMA region is not available after the malloc operations.
> 
> Is there any configuraiton that can change this behavior??
> 
> Thanks
> 
> Cheers
> Ken

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
