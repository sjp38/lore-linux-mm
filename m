Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16BD0C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:27:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA31B21726
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:27:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="bThEovQj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA31B21726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6450E6B0322; Thu, 22 Aug 2019 10:27:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CE686B0323; Thu, 22 Aug 2019 10:27:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BC476B0324; Thu, 22 Aug 2019 10:27:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0043.hostedemail.com [216.40.44.43])
	by kanga.kvack.org (Postfix) with ESMTP id 24C8F6B0322
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:27:32 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B548E6D9F
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:27:31 +0000 (UTC)
X-FDA: 75850291902.21.pain37_777f6bd17a40
X-HE-Tag: pain37_777f6bd17a40
X-Filterd-Recvd-Size: 4722
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com [209.85.210.65])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:27:31 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id c34so5606250otb.7
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:27:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HxSEtX2z/ZJV/B0XcD4BCr1O2HbvzOrzKNcLT4JypFY=;
        b=bThEovQjDRPbGQci1oGNwl98knwGtDbVI9tycUtNpAD5WH/u71hGUtM2xhNVyI5R1f
         fOd+c1dN12ruUyXlb/wEqY3WTmbAJQU4afNsp98FtxyMr/7sUppyEdf1DRZ18OTqR0+C
         AIRU6Cjy4Kh+FYM1N/+/DUewnmCrWcZwia6BI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=HxSEtX2z/ZJV/B0XcD4BCr1O2HbvzOrzKNcLT4JypFY=;
        b=K6ACAsiy6+BulpLvcLn4E1ZzCSsyNUKx5qJR9c/YwaobmSJaoeA3ksLFPM0ayIi2Ej
         QDRIvwSLUYJo2KmA8Nh+HHeND5BaoGD771FXizBXH+9Oxbnj64tQDVf0NRdnJrgordrr
         i/YjigBIwa22/bpIpPPhSoDHutVFjwssK42dxhkiEIAG6ux+Nmm0YnDZqNk6RoFlMCMa
         lXwp/GOfgWpIqTmpiurME8t3Eg0x9qSb2vjac92bX+LBEvWCSyNpHaDkSuP5ChyiPUFI
         chct0nmjGBoB4JrAzyL8Yz9H5DocyLXwvinlxD+rRKhj0a0F7QVpSOk241YhTcLK4nns
         efbg==
X-Gm-Message-State: APjAAAWG6PgOhMjCINrG4lZm0i9njhFWrvfT8qA0ZZRoNDsVUbO+B84O
	kDhnh7xRZq6lrMR0nEeiKocXMwyF84EYWft9EtHpcQ==
X-Google-Smtp-Source: APXvYqzrWuV30uDAlQUdwtvK/fFSj1j/bZ180iv5Fx+HFnPaAc75KsLZP2Z8mNCZI4plTUPZzv1Ihu5g4y0wy4zzZSI=
X-Received: by 2002:a9d:7087:: with SMTP id l7mr1213445otj.281.1566484050304;
 Thu, 22 Aug 2019 07:27:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-5-daniel.vetter@ffwll.ch> <20190820133418.GG29246@ziepe.ca>
 <20190820151810.GG11147@phenom.ffwll.local> <20190821154151.GK11147@phenom.ffwll.local>
 <20190821161635.GC8653@ziepe.ca> <CAKMK7uERsmgFqDVHMCWs=4s_3fHM0eRr7MV6A8Mdv7xVouyxJw@mail.gmail.com>
 <20190822142410.GB8339@ziepe.ca>
In-Reply-To: <20190822142410.GB8339@ziepe.ca>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Thu, 22 Aug 2019 16:27:18 +0200
Message-ID: <CAKMK7uF5CMSUrG2jTYJ9M7tDK_Saxmxk6yLs62tfc-Ozj3p2BQ@mail.gmail.com>
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
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000057, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 4:24 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Thu, Aug 22, 2019 at 10:42:39AM +0200, Daniel Vetter wrote:
>
> > > RDMA has a mutex:
> > >
> > > ib_umem_notifier_invalidate_range_end
> > >   rbt_ib_umem_for_each_in_range
> > >    invalidate_range_start_trampoline
> > >     ib_umem_notifier_end_account
> > >       mutex_lock(&umem_odp->umem_mutex);
> > >
> > > I'm working to delete this path though!
> > >
> > > nonblocking or not follows the start, the same flag gets placed into
> > > the mmu_notifier_range struct passed to end.
> >
> > Ok, makes sense.
> >
> > I guess that also means the might_sleep (I started on that) in
> > invalidate_range_end also needs to be conditional? Or not bother with
> > a might_sleep in invalidate_range_end since you're working on removing
> > the last sleep in there?
>
> I might suggest the same pattern as used for locked, the might_sleep
> unconditionally on the start, and a 2nd might sleep after the IF in
> __mmu_notifier_invalidate_range_end()
>
> Observing that by audit all the callers already have the same locking
> context for start/end

My question was more about enforcing that going forward, since you're
working to remove all the sleeps from invalidate_range_end. I don't
want to add debug annotations which are stricter than what the other
side actually expects. But since currently there is still sleeping
locks in invalidate_range_end I think I'll just stick them in both
places. You can then (re)move it when the cleanup lands.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

