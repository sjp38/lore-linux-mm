Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82742C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:41:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E90122DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:41:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="YgkSS7DQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E90122DD3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC9396B02FB; Wed, 21 Aug 2019 11:41:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA1186B02FC; Wed, 21 Aug 2019 11:41:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB7C16B02FD; Wed, 21 Aug 2019 11:41:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0164.hostedemail.com [216.40.44.164])
	by kanga.kvack.org (Postfix) with ESMTP id A93C36B02FB
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:41:57 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4ECD3B2BD
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:41:57 +0000 (UTC)
X-FDA: 75846850674.21.shoe67_10f06696f173d
X-HE-Tag: shoe67_10f06696f173d
X-Filterd-Recvd-Size: 7794
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:41:56 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id r12so3474570edo.5
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 08:41:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:subject:message-id:mail-followup-to:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=TzES47saF8NKSoTAe4F4vrhi3jlFL+ouHP/sqVU4VOA=;
        b=YgkSS7DQjqyYKcGQZhqNTt8KsjkNcU3e15Siy/lp1QKKNznQVEuAuek7xiD5HvGQ3l
         rxKMLveu/keUgwkclgC0bHPMJ9WDbcN9mWMtNyKF9IzS4GD6/KDOhpxdW1J/mMNlAtpQ
         EQnf1dtH5RzQdObCyV79VbVjMHs6ycyH1m2+c=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:subject:message-id
         :mail-followup-to:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=TzES47saF8NKSoTAe4F4vrhi3jlFL+ouHP/sqVU4VOA=;
        b=CpcL1tG8N18/Fjy/qly+g1wEHPiTnQIXCyChISuGzFEJTZ8pn5ald2pNd5ymZZP6Ti
         1IXwfrrHKh7MKDn68tyu2SvpeVYgbAQNun8N0ff/oZsHaXrKcK8aKT3hpqKCcUs4gNN8
         me1bYlK9H7Kagah/u2rroCVq6DkDVqAL94XGl2rM2Y2ZcBMaWmS8jAJ5Edom+CVVal3D
         Gd2ajjtq5YNAB/XKqFfkxFG7c8HtBoLgCIK90NS2EAd8//ydjk7dUJTEtq9vlq7R/oh+
         WkMpb56uLrRZ7ArRp/1XU6RMuKIV3Nw5jDzHNsNmY1nBTjhZYZfYoSQAzDjbAHfN3BTS
         Ve/A==
X-Gm-Message-State: APjAAAUTk/cIPV8dbSd0vaJmnALBDIF0uZRJc+YCJCwS/qS+2c/HNsV/
	UByno3mb1J5+oAcI88TmwGilvw==
X-Google-Smtp-Source: APXvYqwWJhWck0Z/MmVSLXaA3iVsv5ZDCiK9fhLd/PhSRNH0psxEEEcoafaHzeMpQpUIWsBpQto6SA==
X-Received: by 2002:a50:ef04:: with SMTP id m4mr37875974eds.155.1566402114914;
        Wed, 21 Aug 2019 08:41:54 -0700 (PDT)
Received: from phenom.ffwll.local (212-51-149-96.fiber7.init7.net. [212.51.149.96])
        by smtp.gmail.com with ESMTPSA id a18sm3193136ejp.2.2019.08.21.08.41.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 08:41:53 -0700 (PDT)
Date: Wed, 21 Aug 2019 17:41:51 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: Jason Gunthorpe <jgg@ziepe.ca>, LKML <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/4] mm, notifier: Catch sleeping/blocking for !blockable
Message-ID: <20190821154151.GK11147@phenom.ffwll.local>
Mail-Followup-To: Jason Gunthorpe <jgg@ziepe.ca>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-5-daniel.vetter@ffwll.ch>
 <20190820133418.GG29246@ziepe.ca>
 <20190820151810.GG11147@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190820151810.GG11147@phenom.ffwll.local>
X-Operating-System: Linux phenom 5.2.0-2-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 05:18:10PM +0200, Daniel Vetter wrote:
> On Tue, Aug 20, 2019 at 10:34:18AM -0300, Jason Gunthorpe wrote:
> > On Tue, Aug 20, 2019 at 10:19:02AM +0200, Daniel Vetter wrote:
> > > We need to make sure implementations don't cheat and don't have a
> > > possible schedule/blocking point deeply burried where review can't
> > > catch it.
> > >=20
> > > I'm not sure whether this is the best way to make sure all the
> > > might_sleep() callsites trigger, and it's a bit ugly in the code fl=
ow.
> > > But it gets the job done.
> > >=20
> > > Inspired by an i915 patch series which did exactly that, because th=
e
> > > rules haven't been entirely clear to us.
> > >=20
> > > v2: Use the shiny new non_block_start/end annotations instead of
> > > abusing preempt_disable/enable.
> > >=20
> > > v3: Rebase on top of Glisse's arg rework.
> > >=20
> > > v4: Rebase on top of more Glisse rework.
> > >=20
> > > Cc: Jason Gunthorpe <jgg@ziepe.ca>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: David Rientjes <rientjes@google.com>
> > > Cc: "Christian K=F6nig" <christian.koenig@amd.com>
> > > Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> > > Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> > > Cc: linux-mm@kvack.org
> > > Reviewed-by: Christian K=F6nig <christian.koenig@amd.com>
> > > Reviewed-by: J=E9r=F4me Glisse <jglisse@redhat.com>
> > > Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> > >  mm/mmu_notifier.c | 8 +++++++-
> > >  1 file changed, 7 insertions(+), 1 deletion(-)
> > >=20
> > > diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> > > index 538d3bb87f9b..856636d06ee0 100644
> > > +++ b/mm/mmu_notifier.c
> > > @@ -181,7 +181,13 @@ int __mmu_notifier_invalidate_range_start(stru=
ct mmu_notifier_range *range)
> > >  	id =3D srcu_read_lock(&srcu);
> > >  	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, h=
list) {
> > >  		if (mn->ops->invalidate_range_start) {
> > > -			int _ret =3D mn->ops->invalidate_range_start(mn, range);
> > > +			int _ret;
> > > +
> > > +			if (!mmu_notifier_range_blockable(range))
> > > +				non_block_start();
> > > +			_ret =3D mn->ops->invalidate_range_start(mn, range);
> > > +			if (!mmu_notifier_range_blockable(range))
> > > +				non_block_end();
> >=20
> > If someone Acks all the sched changes then I can pick this for
> > hmm.git, but I still think the existing pre-emption debugging is fine
> > for this use case.
>=20
> Ok, I'll ping Peter Z. for an ack, iirc he was involved.
>=20
> > Also, same comment as for the lockdep map, this needs to apply to the
> > non-blocking range_end also.
>=20
> Hm, I thought the page table locks we're holding there already prevent =
any
> sleeping, so would be redundant? But reading through code I think that'=
s
> not guaranteed, so yeah makes sense to add it for invalidate_range_end
> too. I'll respin once I have the ack/nack from scheduler people.

So I started to look into this, and I'm a bit confused. There's no
_nonblock version of this, so does this means blocking is never allowed,
or always allowed?

From a quick look through implementations I've only seen spinlocks, and
one up_read. So I guess I should wrape this callback in some unconditiona=
l
non_block_start/end, but I'm not sure.

Thanks, Daniel


> > Anyhow, since this series has conflicts with hmm.git it would be best
> > to flow through the whole thing through that tree. If there are no
> > remarks on the first two patches I'll grab them in a few days.
>=20
> Thanks, Daniel
> --=20
> Daniel Vetter
> Software Engineer, Intel Corporation
> http://blog.ffwll.ch

--=20
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

