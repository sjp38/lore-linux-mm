Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id A01DD6B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 11:23:06 -0400 (EDT)
Received: by wgme6 with SMTP id e6so143002161wgm.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 08:23:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9si24988819wiv.44.2015.06.02.08.23.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 08:23:05 -0700 (PDT)
Date: Tue, 2 Jun 2015 17:23:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_frames() helper
Message-ID: <20150602152300.GD17315@quack.suse.cz>
References: <1431522495-4692-1-git-send-email-jack@suse.cz>
 <1431522495-4692-3-git-send-email-jack@suse.cz>
 <20150528162402.19a0a26a5b9eae36aa8050e5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="UHN/qo2QbUvPLonB"
Content-Disposition: inline
In-Reply-To: <20150528162402.19a0a26a5b9eae36aa8050e5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org


--UHN/qo2QbUvPLonB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu 28-05-15 16:24:02, Andrew Morton wrote:
> On Wed, 13 May 2015 15:08:08 +0200 Jan Kara <jack@suse.cz> wrote:
> 
> > Provide new function get_vaddr_frames().  This function maps virtual
> > addresses from given start and fills given array with page frame numbers of
> > the corresponding pages. If given start belongs to a normal vma, the function
> > grabs reference to each of the pages to pin them in memory. If start
> > belongs to VM_IO | VM_PFNMAP vma, we don't touch page structures. Caller
> > must make sure pfns aren't reused for anything else while he is using
> > them.
> > 
> > This function is created for various drivers to simplify handling of
> > their buffers.
> > 
> > Acked-by: Mel Gorman <mgorman@suse.de>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  include/linux/mm.h |  44 +++++++++++
> >  mm/gup.c           | 226 +++++++++++++++++++++++++++++++++++++++++++++++++++++
> 
> That's a lump of new code which many kernels won't be needing.  Can we
> put all this in a new .c file and select it within drivers/media
> Kconfig?
  So the attached patch should do what you had in mind. OK?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--UHN/qo2QbUvPLonB
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-mm-Move-get_vaddr_frames-behind-a-config-option.patch"


--UHN/qo2QbUvPLonB--
