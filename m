Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 828DDC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 15:18:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19468216F4
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 15:18:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="aYdoPW4M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19468216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78B436B000C; Tue, 20 Aug 2019 11:18:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7699A6B000D; Tue, 20 Aug 2019 11:18:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 650E06B000E; Tue, 20 Aug 2019 11:18:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0180.hostedemail.com [216.40.44.180])
	by kanga.kvack.org (Postfix) with ESMTP id 450456B000C
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:18:16 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E47AC181AC9C9
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 15:18:15 +0000 (UTC)
X-FDA: 75843162150.02.cart58_2af192ca85716
X-HE-Tag: cart58_2af192ca85716
X-Filterd-Recvd-Size: 7121
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 15:18:14 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id a21so6728525edt.11
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:18:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:cc:subject:message-id:mail-followup-to
         :references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=WWDlGa28vuh6oyYZfImriVv5lKQQ+IIy5I7j/w5T4Gg=;
        b=aYdoPW4Mvo6YtazOhtnc4ypyhm+qnjOhOXk3ZP2Z58IiJkGhlIoOoy4vFST6kEbhnd
         V1wp+g3K8u0R1/NnJLA6jmPSQTsJFvmcgGqg9sx+I4Ybv+Atic0BqKdJYciuXoPn4GTu
         MVJmP+fAaX12IxRXdt8Yz7aCXLWYef4u5coho=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :mail-followup-to:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=WWDlGa28vuh6oyYZfImriVv5lKQQ+IIy5I7j/w5T4Gg=;
        b=jsVHNBhSxh5qn7f6y012jog83iatEIXfPa7Qd0X253FZdh1y8EYlgI+uVco4wafJ4k
         aQ0c6eGpLbh3+nMRnWAvS9wLDoSWG5jeRTNo5eLll3J/Bzno/E2754gnReJigJKsRXlH
         yVKi7kBwCLzu+tzxBzdYHHNFWDfoe4X0vBCXQajMdTn2vqb2py4NdFmS2+h/1J0txeFt
         vOvc8l3TV65WaEjoZl9WLB2AQ/FQt/Ls7jWwBICXTvAwoUGZdqtlTHMVrKRZFRucQykb
         e0DXkJVvkMyBWD1FEbecsbvOKcrzn42Es/j3u4+F4dAaMnYEEvw0Z8dVQ9hGGjqAjNer
         mA8A==
X-Gm-Message-State: APjAAAVBwboxdDVuTdWjV0/zqZJElhk/oC03j3aLauJwS7At2ZJAzjFl
	RSnLjamLTtNyWhbISnESM47SFg==
X-Google-Smtp-Source: APXvYqwfJ8KGQhdIP9dJFoc5GtYy4qaMCSLIJx0+QTRiFkwBVEZaoyD3Z4vkA0GYiSFo+zVsSSDxmA==
X-Received: by 2002:a17:906:cc81:: with SMTP id oq1mr26923934ejb.124.1566314293557;
        Tue, 20 Aug 2019 08:18:13 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id oa21sm2669585ejb.60.2019.08.20.08.18.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Aug 2019 08:18:12 -0700 (PDT)
Date: Tue, 20 Aug 2019 17:18:10 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/4] mm, notifier: Catch sleeping/blocking for !blockable
Message-ID: <20190820151810.GG11147@phenom.ffwll.local>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190820133418.GG29246@ziepe.ca>
X-Operating-System: Linux phenom 5.2.0-2-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 10:34:18AM -0300, Jason Gunthorpe wrote:
> On Tue, Aug 20, 2019 at 10:19:02AM +0200, Daniel Vetter wrote:
> > We need to make sure implementations don't cheat and don't have a
> > possible schedule/blocking point deeply burried where review can't
> > catch it.
> >=20
> > I'm not sure whether this is the best way to make sure all the
> > might_sleep() callsites trigger, and it's a bit ugly in the code flow=
.
> > But it gets the job done.
> >=20
> > Inspired by an i915 patch series which did exactly that, because the
> > rules haven't been entirely clear to us.
> >=20
> > v2: Use the shiny new non_block_start/end annotations instead of
> > abusing preempt_disable/enable.
> >=20
> > v3: Rebase on top of Glisse's arg rework.
> >=20
> > v4: Rebase on top of more Glisse rework.
> >=20
> > Cc: Jason Gunthorpe <jgg@ziepe.ca>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: "Christian K=F6nig" <christian.koenig@amd.com>
> > Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> > Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> > Cc: linux-mm@kvack.org
> > Reviewed-by: Christian K=F6nig <christian.koenig@amd.com>
> > Reviewed-by: J=E9r=F4me Glisse <jglisse@redhat.com>
> > Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> >  mm/mmu_notifier.c | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> > index 538d3bb87f9b..856636d06ee0 100644
> > +++ b/mm/mmu_notifier.c
> > @@ -181,7 +181,13 @@ int __mmu_notifier_invalidate_range_start(struct=
 mmu_notifier_range *range)
> >  	id =3D srcu_read_lock(&srcu);
> >  	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hli=
st) {
> >  		if (mn->ops->invalidate_range_start) {
> > -			int _ret =3D mn->ops->invalidate_range_start(mn, range);
> > +			int _ret;
> > +
> > +			if (!mmu_notifier_range_blockable(range))
> > +				non_block_start();
> > +			_ret =3D mn->ops->invalidate_range_start(mn, range);
> > +			if (!mmu_notifier_range_blockable(range))
> > +				non_block_end();
>=20
> If someone Acks all the sched changes then I can pick this for
> hmm.git, but I still think the existing pre-emption debugging is fine
> for this use case.

Ok, I'll ping Peter Z. for an ack, iirc he was involved.

> Also, same comment as for the lockdep map, this needs to apply to the
> non-blocking range_end also.

Hm, I thought the page table locks we're holding there already prevent an=
y
sleeping, so would be redundant? But reading through code I think that's
not guaranteed, so yeah makes sense to add it for invalidate_range_end
too. I'll respin once I have the ack/nack from scheduler people.

> Anyhow, since this series has conflicts with hmm.git it would be best
> to flow through the whole thing through that tree. If there are no
> remarks on the first two patches I'll grab them in a few days.

Thanks, Daniel
--=20
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

