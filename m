Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 38186900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 18:29:14 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so81145550pdb.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 15:29:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h1si28418557pdp.25.2015.06.02.15.29.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 15:29:13 -0700 (PDT)
Date: Tue, 2 Jun 2015 15:29:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_frames() helper
Message-Id: <20150602152912.4851e6fd4213828ddf7eb5b2@linux-foundation.org>
In-Reply-To: <20150602152300.GD17315@quack.suse.cz>
References: <1431522495-4692-1-git-send-email-jack@suse.cz>
	<1431522495-4692-3-git-send-email-jack@suse.cz>
	<20150528162402.19a0a26a5b9eae36aa8050e5@linux-foundation.org>
	<20150602152300.GD17315@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org

On Tue, 2 Jun 2015 17:23:00 +0200 Jan Kara <jack@suse.cz> wrote:

> > That's a lump of new code which many kernels won't be needing.  Can we
> > put all this in a new .c file and select it within drivers/media
> > Kconfig?
>   So the attached patch should do what you had in mind. OK?

lgtm.

>  drivers/gpu/drm/exynos/Kconfig      |   1 +
>  drivers/media/platform/omap/Kconfig |   1 +
>  drivers/media/v4l2-core/Kconfig     |   1 +
>  mm/Kconfig                          |   3 +
>  mm/Makefile                         |   1 +
>  mm/frame-vec.c                      | 233 ++++++++++++++++++++++++++++++++++++

But frame_vector.c would be a more pleasing name.  For `struct frame_vector'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
