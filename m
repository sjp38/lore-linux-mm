Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64CB88E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 05:28:49 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t7so34840653edr.21
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 02:28:49 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 91si352738edy.438.2019.01.04.02.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 02:28:47 -0800 (PST)
Date: Fri, 4 Jan 2019 11:28:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm/vmalloc: fix size check for
 remap_vmalloc_range_partial()
Message-ID: <20190104102846.GN31793@dhcp22.suse.cz>
References: <20190103145954.16942-1-rpenyaev@suse.de>
 <20190103145954.16942-2-rpenyaev@suse.de>
 <20190103151357.GR31793@dhcp22.suse.cz>
 <dba7cb2c2882e034c8c99b09a432313a@suse.de>
 <20190103194054.GB31793@dhcp22.suse.cz>
 <5502b64d6c508f5432386d2cfe999844@suse.de>
 <20190104093808.GJ31793@dhcp22.suse.cz>
 <4630dd7797fc7934f98c01ea789105a8@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4630dd7797fc7934f98c01ea789105a8@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Fri 04-01-19 11:21:39, Roman Penyaev wrote:
> On 2019-01-04 10:38, Michal Hocko wrote:
> 
> [...]
> 
> > > >
> > > > OK, my response was more confusing than I intended. I meant to say. Is
> > > > there any in kernel code that would allow the bug have had in mind?
> > > > In other words can userspace trick any existing code?
> > > 
> > > In theory any existing caller of remap_vmalloc_range() which does
> > > not have an explicit size check should trigger an oops, e.g. this is
> > > a good candidate:
> > > 
> > > *** drivers/media/usb/stkwebcam/stk-webcam.c:
> > > v4l_stk_mmap[789]              ret = remap_vmalloc_range(vma,
> > > sbuf->buffer,
> > > 0);
> > 
> > Hmm, sbuf->buffer is allocated in stk_setup_siobuf to have
> > buf->v4lbuf.length. mmap callback maps this buffer to the vma size and
> > that is indeed not enforced to be <= length AFAICS. So you are right!
> > 
> > Can we have an example in the changelog please?
> 
> You mean to resend this particular patch with the list of possible
> candidates for oops in a comment message?  Sure thing.

I would just reply to the original patch with an updated changelog
wording (to include the above example and explain how the vma setup is
completely independent on the buffer allocation and ask Andrew to update
the changelog of the patch that is already in the mmotm tree).

Thanks!
-- 
Michal Hocko
SUSE Labs
