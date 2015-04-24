Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 62FBA6B0038
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:08:19 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so55649228wgy.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 09:08:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si20120971wjx.82.2015.04.24.09.08.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 09:08:17 -0700 (PDT)
Date: Fri, 24 Apr 2015 18:08:11 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/9 v2] Helper to abstract vma handling in media layer
Message-ID: <20150424160811.GB18074@quack.suse.cz>
References: <1426593399-6549-1-git-send-email-jack@suse.cz>
 <20150402150258.GA31277@quack.suse.cz>
 <551D5F7C.4080400@xs4all.nl>
 <553A2229.5040509@samsung.com>
 <553A23F9.1080504@xs4all.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <553A23F9.1080504@xs4all.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Verkuil <hverkuil@xs4all.nl>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Jan Kara <jack@suse.cz>, linux-media@vger.kernel.org, Hans Verkuil <hans.verkuil@cisco.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Pawel Osciak <pawel@osciak.com>

On Fri 24-04-15 13:07:37, Hans Verkuil wrote:
> Hi Marek,
> 
> On 04/24/2015 12:59 PM, Marek Szyprowski wrote:
> > Dear All,
> > 
> > On 2015-04-02 17:25, Hans Verkuil wrote:
> >> On 04/02/2015 05:02 PM, Jan Kara wrote:
> >>>    Hello,
> >>>
> >>> On Tue 17-03-15 12:56:30, Jan Kara wrote:
> >>>>    After a long pause I'm sending second version of my patch series to abstract
> >>>> vma handling from the various media drivers. After this patch set drivers have
> >>>> to know much less details about vmas, their types, and locking. My motivation
> >>>> for the series is that I want to change get_user_pages() locking and I want to
> >>>> handle subtle locking details in as few places as possible.
> >>>>
> >>>> The core of the series is the new helper get_vaddr_pfns() which is given a
> >>>> virtual address and it fills in PFNs into provided array. If PFNs correspond to
> >>>> normal pages it also grabs references to these pages. The difference from
> >>>> get_user_pages() is that this function can also deal with pfnmap, mixed, and io
> >>>> mappings which is what the media drivers need.
> >>>>
> >>>> I have tested the patches with vivid driver so at least vb2 code got some
> >>>> exposure. Conversion of other drivers was just compile-tested so I'd like to
> >>>> ask respective maintainers if they could have a look.  Also I'd like to ask mm
> >>>> folks to check patch 2/9 implementing the helper. Thanks!
> >>>    Ping? Any reactions?
> >> For patch 1/9:
> >>
> >> Acked-by: Hans Verkuil <hans.verkuil@cisco.com>
> >>
> >> For the other patches I do not feel qualified to give Acks. I've Cc-ed Pawel and
> >> Marek who have a better understanding of the mm internals than I do. Hopefully
> >> they can review the code.
> >>
> >> It definitely looks like a good idea, and if nobody else will comment on the vb2
> >> patches in the next 2 weeks, then I'll try to review it myself (for whatever that's
> >> worth).
> > 
> > I'm really sorry that I didn't manage to find time to review this 
> > patchset. I really
> > like the idea of moving pfn lookup from videobuf2/driver to some common 
> > code in mm
> > and it is really great that someone managed to provide nice generic code 
> > for it.
> > 
> > I've applied the whole patchset onto v4.0 and tested it on Odroid U3 
> > (with some
> > additional patches). VideoBuf2-dc works still fine with USERPTR gathered 
> > from other's
> > device mmaped buffer. You can add my:
> > 
> > Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Tested-by: Marek Szyprowski <m.szyprowski@samsung.com>
> 
> Thanks!
  Thank you both for having a look at the patches!

> > for the patches 1-8. Patch 9/9 doesn't apply anymore, so I've skipped 
> > it. Patch 2
> > needs a small fixup - you need to add '#include <linux/vmalloc.h>', 
> > because otherwise
> > it doesn't compile. There have been also a minor conflict to be resolved 
> > in patch 7.
> 
> I've just added patch 1/9 to my pull request for 4.2. But for patch 2/9 I need
> Acks from the mm maintainers. I think it makes sense if patches 2-8 all go
> in together via the linux-media tree. Jan, can you reach out to the right
> devs to get Acks?
  Sure, I'll ping some mm guys explicitely.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
