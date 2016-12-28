Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE2656B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 03:32:17 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id hb5so88725697wjc.2
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 00:32:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 187si49309374wmx.141.2016.12.28.00.32.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 00:32:16 -0800 (PST)
Date: Wed, 28 Dec 2016 09:32:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] lib: bitmap: introduce
 bitmap_find_next_zero_area_and_size
Message-ID: <20161228083211.GA11470@dhcp22.suse.cz>
References: <CGME20161226041809epcas5p1981244de55764c10f1a80d80346f3664@epcas5p1.samsung.com>
 <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
 <20161227100535.GB7662@dhcp22.suse.cz>
 <58634274.5060205@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <58634274.5060205@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, mina86@mina86.com, m.szyprowski@samsung.com, gregory.0xf0@gmail.com, laurent.pinchart@ideasonboard.com, akinobu.mita@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Wed 28-12-16 13:41:24, Jaewon Kim wrote:
> 
> 
> On 2016e?? 12i?? 27i? 1/4  19:05, Michal Hocko wrote:
[...]
> > Who is going to use this function? I do not see any caller introduced by
> > this patch.
>
> Hi
> I did not add caller in this patch.

it is preferable to add the caller(s) in the same patch to see the
benefit of the new helper.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
