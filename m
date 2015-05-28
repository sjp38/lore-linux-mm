Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 98E556B006E
	for <linux-mm@kvack.org>; Thu, 28 May 2015 19:24:04 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so52214962pdb.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 16:24:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pf6si5714888pbb.67.2015.05.28.16.24.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 16:24:03 -0700 (PDT)
Date: Thu, 28 May 2015 16:24:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_frames() helper
Message-Id: <20150528162402.19a0a26a5b9eae36aa8050e5@linux-foundation.org>
In-Reply-To: <1431522495-4692-3-git-send-email-jack@suse.cz>
References: <1431522495-4692-1-git-send-email-jack@suse.cz>
	<1431522495-4692-3-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org

On Wed, 13 May 2015 15:08:08 +0200 Jan Kara <jack@suse.cz> wrote:

> Provide new function get_vaddr_frames().  This function maps virtual
> addresses from given start and fills given array with page frame numbers of
> the corresponding pages. If given start belongs to a normal vma, the function
> grabs reference to each of the pages to pin them in memory. If start
> belongs to VM_IO | VM_PFNMAP vma, we don't touch page structures. Caller
> must make sure pfns aren't reused for anything else while he is using
> them.
> 
> This function is created for various drivers to simplify handling of
> their buffers.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/linux/mm.h |  44 +++++++++++
>  mm/gup.c           | 226 +++++++++++++++++++++++++++++++++++++++++++++++++++++

That's a lump of new code which many kernels won't be needing.  Can we
put all this in a new .c file and select it within drivers/media
Kconfig?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
