Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AE00C433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 07:10:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC45D20656
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 07:10:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="ChRXyIAY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC45D20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61BBC6B0003; Thu, 15 Aug 2019 03:10:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CC3B6B0005; Thu, 15 Aug 2019 03:10:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BB5F6B0007; Thu, 15 Aug 2019 03:10:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0087.hostedemail.com [216.40.44.87])
	by kanga.kvack.org (Postfix) with ESMTP id 2A6A46B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 03:10:20 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BC2D38248AA7
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 07:10:19 +0000 (UTC)
X-FDA: 75823788558.19.crate46_2c536b93093a
X-HE-Tag: crate46_2c536b93093a
X-Filterd-Recvd-Size: 9394
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 07:10:18 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id z51so1301659edz.13
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:10:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:cc:subject:message-id:mail-followup-to
         :references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=MDJNuF+hut+3YRzITm+axnt/d3tCzk1EPMOdFx9+DEE=;
        b=ChRXyIAYC7Rv8Y/vZMRO+O0Vlh5DAbIO5arU41q9pJ83DPuxW7q/ClkJgPqFUTZdkI
         RFRAoqFle60uB8sY67kiMD84/VinSId3gTA/SLZHu2D0j6h0ZI94eO3b9q/2tAqdpX+c
         FhwIh8fhcacKOZx661IGz8Odmwog/6hD0LIYg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :mail-followup-to:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=MDJNuF+hut+3YRzITm+axnt/d3tCzk1EPMOdFx9+DEE=;
        b=sUgSoaNf8IsxLm3/k48FkNYmswNBJanJWEXYfWek5SWq6MU+CXVgu0fHStpTWFearM
         jTj/YQFkMGdNCtdoXfXlg5JheahR+oabWwFIySMPRAry1cdacT1IPuOum5tg6yAFZKFl
         xP5yjsZgClg3pruA/oeFWz2gyQkXF5Q8qMnhEjuZCRkslnPVPx208rQu+20f63Nm/dPB
         sUA69XyCfa63wvtfmW0srsbgYNgIXF4bQgf7GxXGCrboKGEilCYNlzWKQ8NY9zmRuKvd
         oCvmDtraXZgSkwZTc0oHYOXqavgTeskP8VP4A+Yz8EWT8V7mjb7jphnUvWZpWUnY+aTt
         SCWw==
X-Gm-Message-State: APjAAAUHL5982oTunFDOqPzRWI/LEp79JUpdyWbI0x8oh6nsLkxw0daz
	2YrslOSOYwWfmqdC+KRR1sljggg8Ut9wFQ==
X-Google-Smtp-Source: APXvYqzeqsYGya7a5gyG8JjAs2HpNqhI6YY0zlDjUM0vg0ax5p423oBpWZJFMYcam0b+ez79KuLR5w==
X-Received: by 2002:a50:c101:: with SMTP id l1mr854278edf.157.1565853017629;
        Thu, 15 Aug 2019 00:10:17 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id q21sm257841ejo.76.2019.08.15.00.10.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Aug 2019 00:10:16 -0700 (PDT)
Date: Thu, 15 Aug 2019 09:10:14 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/5] mm, notifier: Add a lockdep map for
 invalidate_range_start
Message-ID: <20190815071014.GC7444@phenom.ffwll.local>
Mail-Followup-To: Jason Gunthorpe <jgg@ziepe.ca>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Daniel Vetter <daniel.vetter@intel.com>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-5-daniel.vetter@ffwll.ch>
 <20190815000959.GD11200@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190815000959.GD11200@ziepe.ca>
X-Operating-System: Linux phenom 4.19.0-5-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 09:09:59PM -0300, Jason Gunthorpe wrote:
> On Wed, Aug 14, 2019 at 10:20:26PM +0200, Daniel Vetter wrote:
> > This is a similar idea to the fs_reclaim fake lockdep lock. It's
> > fairly easy to provoke a specific notifier to be run on a specific
> > range: Just prep it, and then munmap() it.
> >=20
> > A bit harder, but still doable, is to provoke the mmu notifiers for
> > all the various callchains that might lead to them. But both at the
> > same time is really hard to reliable hit, especially when you want to
> > exercise paths like direct reclaim or compaction, where it's not
> > easy to control what exactly will be unmapped.
> >=20
> > By introducing a lockdep map to tie them all together we allow lockde=
p
> > to see a lot more dependencies, without having to actually hit them
> > in a single challchain while testing.
> >=20
> > Aside: Since I typed this to test i915 mmu notifiers I've only rolled
> > this out for the invaliate_range_start callback. If there's
> > interest, we should probably roll this out to all of them. But my
> > undestanding of core mm is seriously lacking, and I'm not clear on
> > whether we need a lockdep map for each callback, or whether some can
> > be shared.
>=20
> I was thinking about doing something like this..
>=20
> IMHO only range_end needs annotation, the other ops are either already
> non-sleeping or only used by KVM.

This isnt' about sleeping, this is about locking loops. And the biggest
risk for that is from driver code, and at least hmm_mirror only has the
driver code callback on invalidate_range_start. Once thing I discovered
using this (and it would be really hard to spot, it's deeply neested) is
that i915 userptr.

Even if i915 userptr would use hmm_mirror (to fix the issue you mention
below), if we then switch the annotation to invalidate_range_end nothing
interesting would ever come from this. Well, the only thing it'd catch is
issues in hmm_mirror, but I think core mm review will catch that before i=
t
reaches us :-)

> BTW, I have found it strange that i915 only uses
> invalidate_range_start. Not really sure how it is able to do
> that. Would love to know the answer :)

I suspect it's broken :-/ Our userptr is ... not the best. Part of the
motivation here.

> > Reviewed-by: J=E9r=F4me Glisse <jglisse@redhat.com>
> > Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> >  include/linux/mmu_notifier.h | 6 ++++++
> >  mm/mmu_notifier.c            | 7 +++++++
> >  2 files changed, 13 insertions(+)
> >=20
> > diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifie=
r.h
> > index b6c004bd9f6a..9dd38c32fc53 100644
> > +++ b/include/linux/mmu_notifier.h
> > @@ -42,6 +42,10 @@ enum mmu_notifier_event {
> > =20
> >  #ifdef CONFIG_MMU_NOTIFIER
> > =20
> > +#ifdef CONFIG_LOCKDEP
> > +extern struct lockdep_map __mmu_notifier_invalidate_range_start_map;
> > +#endif
>=20
> I wonder what the trade off is having a global map vs a map in each
> mmu_notifier_mm ?

Less reports, specifically no reports involving multiple different mmu
notifiers to build the entire chain. But I'm assuming it's possible to
combine them in one mm (kvm+gpu+infiniband in one process sounds like
something someone could reasonably do), and it will help to make sure
everyone follows the same rules.
>=20
> >  /*
> >   * The mmu notifier_mm structure is allocated and installed in
> >   * mm->mmu_notifier_mm inside the mm_take_all_locks() protected
> > @@ -310,10 +314,12 @@ static inline void mmu_notifier_change_pte(stru=
ct mm_struct *mm,
> >  static inline void
> >  mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range=
)
> >  {
> > +	lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
> >  	if (mm_has_notifiers(range->mm)) {
> >  		range->flags |=3D MMU_NOTIFIER_RANGE_BLOCKABLE;
> >  		__mmu_notifier_invalidate_range_start(range);
> >  	}
> > +	lock_map_release(&__mmu_notifier_invalidate_range_start_map);
> >  }
>=20
> Also range_end should have this too - it has all the same
> constraints. I think it can share the map. So 'range_start_map' is
> probably not the right name.
>=20
> It may also make some sense to do a dummy acquire/release under the
> mm_take_all_locks() to forcibly increase map coverage and reduce the
> scenario complexity required to hit bugs.
>=20
> And if we do decide on the reclaim thing in my other email then the
> reclaim dependency can be reliably injected by doing:
>=20
>  fs_reclaim_acquire();
>  lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
>  lock_map_release(&__mmu_notifier_invalidate_range_start_map);
>  fs_reclaim_release();
>=20
> If I understand lockdep properly..

Ime fs_reclaim injects the mmu_notifier map here reliably as soon as
you've thrown out the first pagecache mmap on any process. That "make sur=
e
we inject it quickly" is why the lockdep is _outside_ of the
mm_has_notifiers() check. So no further injection needed imo.
-Daniel
--=20
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

