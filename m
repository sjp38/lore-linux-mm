Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 762F86B0070
	for <linux-mm@kvack.org>; Mon, 11 May 2015 10:47:14 -0400 (EDT)
Received: by wgbhc8 with SMTP id hc8so30378165wgb.2
        for <linux-mm@kvack.org>; Mon, 11 May 2015 07:47:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3si124427wiw.60.2015.05.11.07.47.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 May 2015 07:47:12 -0700 (PDT)
Date: Mon, 11 May 2015 15:47:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_frames() helper
Message-ID: <20150511144707.GP2462@suse.de>
References: <1430897296-5469-1-git-send-email-jack@suse.cz>
 <1430897296-5469-3-git-send-email-jack@suse.cz>
 <20150508144922.GO2462@suse.de>
 <20150511140019.GD25034@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150511140019.GD25034@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org

On Mon, May 11, 2015 at 04:00:19PM +0200, Jan Kara wrote:
> > > +int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
> > > +		     bool write, bool force, struct frame_vector *vec)
> > > +{
> > > +	struct mm_struct *mm = current->mm;
> > > +	struct vm_area_struct *vma;
> > > +	int ret = 0;
> > > +	int err;
> > > +	int locked = 1;
> > > +
> > 
> > bool locked.
>   It cannot be bool. It is passed to get_user_pages_locked() which expects
> int *.
> 

My bad.

> > > +int frame_vector_to_pages(struct frame_vector *vec)
> > > +{
> > 
> > I think it's probably best to make the relevant counters in frame_vector
> > signed and limit the maximum possible size of it. It's still not putting
> > any practical limit on the size of the frame_vector.
>
>   I don't see a reason why counters in frame_vector should be signed... Can
> you share your reason?  I've added a check into frame_vector_create() to
> limit number of frames to INT_MAX / sizeof(void *) / 2 to avoid arithmetics
> overflow. Thanks for review!
> 

Only that the return value of frame_vector_to_pages() returns int where
as the potential range that is converted is unsigned int. I don't think
there are any mistakes dealing with signed/unsigned but I don't see any
advantage of using unsigned either and limiting it to INT_MAX either.
It's not a big deal.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
