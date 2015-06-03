Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 84C32900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 05:34:48 -0400 (EDT)
Received: by wibdt2 with SMTP id dt2so5385523wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 02:34:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gh11si213438wjc.11.2015.06.03.02.34.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Jun 2015 02:34:46 -0700 (PDT)
Date: Wed, 3 Jun 2015 11:34:43 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_frames() helper
Message-ID: <20150603093443.GF13054@quack.suse.cz>
References: <1431522495-4692-1-git-send-email-jack@suse.cz>
 <1431522495-4692-3-git-send-email-jack@suse.cz>
 <20150528162402.19a0a26a5b9eae36aa8050e5@linux-foundation.org>
 <20150602152300.GD17315@quack.suse.cz>
 <20150602152912.4851e6fd4213828ddf7eb5b2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="SkvwRMAIpAhPCcCJ"
Content-Disposition: inline
In-Reply-To: <20150602152912.4851e6fd4213828ddf7eb5b2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org


--SkvwRMAIpAhPCcCJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 02-06-15 15:29:12, Andrew Morton wrote:
> On Tue, 2 Jun 2015 17:23:00 +0200 Jan Kara <jack@suse.cz> wrote:
> 
> > > That's a lump of new code which many kernels won't be needing.  Can we
> > > put all this in a new .c file and select it within drivers/media
> > > Kconfig?
> >   So the attached patch should do what you had in mind. OK?
> 
> lgtm.
> 
> >  drivers/gpu/drm/exynos/Kconfig      |   1 +
> >  drivers/media/platform/omap/Kconfig |   1 +
> >  drivers/media/v4l2-core/Kconfig     |   1 +
> >  mm/Kconfig                          |   3 +
> >  mm/Makefile                         |   1 +
> >  mm/frame-vec.c                      | 233 ++++++++++++++++++++++++++++++++++++
> 
> But frame_vector.c would be a more pleasing name.  For `struct frame_vector'.
  OK, makes sense. Updated patch attached.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--SkvwRMAIpAhPCcCJ
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-mm-Move-get_vaddr_frames-behind-a-config-option.patch"


--SkvwRMAIpAhPCcCJ--
