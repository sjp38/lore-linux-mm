Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D29A9C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 09:34:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B03B2332A
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 09:34:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="RWdDCknA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B03B2332A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDF916B02AF; Wed, 21 Aug 2019 05:34:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C90E96B02B0; Wed, 21 Aug 2019 05:34:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B573D6B02B1; Wed, 21 Aug 2019 05:34:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD466B02AF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 05:34:21 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 33957AF7B
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 09:34:21 +0000 (UTC)
X-FDA: 75845924322.17.knee36_8aed2c494921
X-HE-Tag: knee36_8aed2c494921
X-Filterd-Recvd-Size: 5409
Received: from mail-oi1-f194.google.com (mail-oi1-f194.google.com [209.85.167.194])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 09:34:19 +0000 (UTC)
Received: by mail-oi1-f194.google.com with SMTP id l2so1116288oil.0
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 02:34:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jrMnd9Dw4BIbl105NPubLNKMx+vt1yB2bVw1jRY/PoI=;
        b=RWdDCknAmMlPEQ9u6yUMbaKojAWU9G+zSGrTlsA+5Fkb6D5PPhV3wXAdyHPQHxX3o2
         vq6qCQtWx7WMlW8Wcwk/fdYFN48LUhyp1O9fbzd3V40UTaKzdmNXguxv3DgFH0nqPlyM
         j37eomYfP4oBSb5y02UJPiGrztvAL9IJTDwk4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=jrMnd9Dw4BIbl105NPubLNKMx+vt1yB2bVw1jRY/PoI=;
        b=ZCnDWDeGpEV5o4BcoY55I+9rSpWioQlf9ls9QFk9qgv7Gw70meyRTfltf2TpaC4LZM
         D4h510CyTdfiYP3xRP5H9U6/VwzYzotHuoihmMFz9wlqU8zs+PvGNaV+K8ADAOV4FZRV
         giCBychOUyHf5tLxP2yRgeG6GVMmKGhVNJo7glc1LBhK0PUgpwiwkv7XZTm0EuevhXAc
         vQV432LnAcCkq6hbezdRmk3XMWOjo5T5QNjm1agLZ0Efu52mNa4yWuS/WgAc4otgByD+
         CHQrYjqkAAsn9z1k0dfNsA+rm6UkoKdt6pDwLMqjDX/oToFNMCeW1TNZY/fhGJBXgkSo
         wzqg==
X-Gm-Message-State: APjAAAUyjM4vE9eFnsUTTJYF6bBFXX0KeyIBIxnNgJplM3iftBfZqyug
	4r7FtCyc/6V24xZhTaNjNtZiD5355RYQOm0tv75wVQ==
X-Google-Smtp-Source: APXvYqz6Xkt/CCbaeKtV6kQUpHjgnS2QNd5FOt7p4vifuidxlIYHRXgS2fDGVa3/892Mj7QMqJOfxhRNKJMmZoX5PgE=
X-Received: by 2002:aca:da08:: with SMTP id r8mr2776211oig.101.1566380058381;
 Wed, 21 Aug 2019 02:34:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-5-daniel.vetter@ffwll.ch> <20190820133418.GG29246@ziepe.ca>
 <20190820151810.GG11147@phenom.ffwll.local> <20190820152712.GH29246@ziepe.ca>
In-Reply-To: <20190820152712.GH29246@ziepe.ca>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Wed, 21 Aug 2019 11:34:06 +0200
Message-ID: <CAKMK7uGuH_Lvzf+M3Vast-RFS6Dr70F+Q4U_aSHuR1TpJg02SQ@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm, notifier: Catch sleeping/blocking for !blockable
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Daniel Vetter <daniel.vetter@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 9:33 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Tue, Aug 20, 2019 at 05:18:10PM +0200, Daniel Vetter wrote:
> > > > diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> > > > index 538d3bb87f9b..856636d06ee0 100644
> > > > +++ b/mm/mmu_notifier.c
> > > > @@ -181,7 +181,13 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
> > > >   id = srcu_read_lock(&srcu);
> > > >   hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) {
> > > >           if (mn->ops->invalidate_range_start) {
> > > > -                 int _ret = mn->ops->invalidate_range_start(mn, range);
> > > > +                 int _ret;
> > > > +
> > > > +                 if (!mmu_notifier_range_blockable(range))
> > > > +                         non_block_start();
> > > > +                 _ret = mn->ops->invalidate_range_start(mn, range);
> > > > +                 if (!mmu_notifier_range_blockable(range))
> > > > +                         non_block_end();
> > >
> > > If someone Acks all the sched changes then I can pick this for
> > > hmm.git, but I still think the existing pre-emption debugging is fine
> > > for this use case.
> >
> > Ok, I'll ping Peter Z. for an ack, iirc he was involved.
> >
> > > Also, same comment as for the lockdep map, this needs to apply to the
> > > non-blocking range_end also.
> >
> > Hm, I thought the page table locks we're holding there already prevent any
> > sleeping, so would be redundant?
>
> AFAIK no. All callers of invalidate_range_start/end pairs do so a few
> lines apart and don't change their locking in between - thus since
> start can block so can end.
>
> Would love to know if that is not true??

Yeah I reviewed them, I think I mixed up a discussion I had a while
ago with Jerome. It's a bit tricky to follow in the code since in some
places ->invalidate_range and ->invalidate_range_end seem to be called
from the same place, in others not at all.

> Similarly I've also been idly wondering if we should add a
> 'might_sleep()' to invalidate_rangestart/end() to make this constraint
> clear & tested to the mm side?

Hm, sounds like a useful idea. Since in general you wont test with mmu
notifiers, but they could happen, and then they will block for at
least some mutex usually. I'll throw that as an idea on top for the
next round.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

