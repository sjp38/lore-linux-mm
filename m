Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AE1AC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 14:20:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAC0020870
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 14:20:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAC0020870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FAA88E0002; Tue, 29 Jan 2019 09:20:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AA2D8E0001; Tue, 29 Jan 2019 09:20:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C06A8E0002; Tue, 29 Jan 2019 09:20:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF7F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:20:10 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q63so16987475pfi.19
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 06:20:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:organization:in-reply-to:cc
         :references:message-id:user-agent:subject:date;
        bh=WpNPsCJ3M0BUB0vNosdbCbR/vzU8wN9Zrw5bwuDaXns=;
        b=gC3eGazphTBBMQza5UcJgrCLC0+pgvwdDrEesPevfEUcbUJm/N42AOyhiuUytg7pFG
         GtFOphRc8MJunVcXBrFK8LZgoUJr9Wf0paDK10PI8oKkqh+7yADr1jQcQuyUW3LrOABX
         OS80nT/fPTpneVfzEnZmLfsIH/wxm3i0WsMvAePExfs1DztdMOe4gIxTFPahQr2cBPTH
         jESOSuo4EP7XKG81ZZMmdAruB7rmdsNyCPfQaMmwzy8im563UbarRVuJ5J6UPrZnwUFH
         vhTiOZ+7PeS+kgFQ4vsJFNKmm6w8F+p7gdXyK3x7w9olidsLTGz7KyzuYc6F9H5IHo6H
         RfNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=joonas.lahtinen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcRmYwBDtgFXYV6R/vSyO8jKrxSfouRGkHrdZ3Phu8wQz8z8kJV
	rsAJuF0AKiOXeKfqpo5FjAd4t2McVNhzqWW31t40M5mLw9EkzUoCLPEB5AFpXxCZo8WHWAWsXeG
	Hh9pUD7ojxmnIIxqXIrHgbabuEikNNk5SN+Frsz05Eqe0jhIM/HQrX7q7ZppF04c/Ow==
X-Received: by 2002:a63:f141:: with SMTP id o1mr24133705pgk.134.1548771609656;
        Tue, 29 Jan 2019 06:20:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7tIV32Jq4+/VIwQszE7aedBUTY0Sabwb+C4X3gjUvVPcwMo3f1AfivcsgKkD0q/QTer0QK
X-Received: by 2002:a63:f141:: with SMTP id o1mr24133649pgk.134.1548771608699;
        Tue, 29 Jan 2019 06:20:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548771608; cv=none;
        d=google.com; s=arc-20160816;
        b=HdOZdiOD+cl5ChdW+8QAkHKQPUlaeXwKP4FQwf8ppteSRWSXR3nDKClMCzJcC22x89
         t19AMfJh0Ut/rVO0l7W54/QgUetU53HahYSSUTdSY+jpGCjG3PLwJ5EELKz1xr0/lwa5
         ukLD1GoRj8Q0jPVfAzdE+xrWv3QUX0l3MnP0491E5PKnXpj6tmzTaihXJgfeWkpXtE5Y
         oNkTImMiex8miMx8ltX5RDsnYpKtckxeJD2+0gWomU5U12//JfOhLjodrPg1TP8TStV2
         KdFpCAj5IE+f3BQwhkhN87HPxICtWohlP3dAdFxWayTeVunv612XWNLxb3xQGBXWa/Dm
         VKLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to
         :organization:from:to:content-transfer-encoding:mime-version;
        bh=WpNPsCJ3M0BUB0vNosdbCbR/vzU8wN9Zrw5bwuDaXns=;
        b=SmzZU/3DA4WqXeHlVDRe/rTV/KvucEaoIJVSuE3wDdeIff4rUJmPvNacFWjfK1dXE5
         cjfWF33ZsxTRvV9ZM5LOQk7RKYEHQ8pLJJrtHjwhQ/UcynMczOClmyERNw4kJEtkwUW+
         wdSQion4U31zkE/Ud4oXsqzKYD80p/JIsoJ9UT/SbivxMs2ONcP0GuwtvXdeOhZn3Ms4
         fGDMU55l3yaHVonREeX7hG9vXL3yx81dywfl71Ds58dN5AQyWeGcWJP03OE7UR6ZAHUo
         Heg1lKvgu7gADQdEkKYmTIsubW0FmMrIRhI4NTVJV1AO1wLQf5CdyIjIZemhaPvmpHPK
         1gtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=joonas.lahtinen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x66si35538055pfk.73.2019.01.29.06.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 06:20:08 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=joonas.lahtinen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Jan 2019 06:20:08 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,537,1539673200"; 
   d="scan'208";a="110714506"
Received: from jlahtine-desk.ger.corp.intel.com (HELO localhost) ([10.251.87.6])
  by orsmga007.jf.intel.com with ESMTP; 29 Jan 2019 06:20:00 -0800
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: Jerome Glisse <jglisse@redhat.com>
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
In-Reply-To: <20190124153032.GA5030@redhat.com>
Cc: linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>,
 Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, kvm@vger.kernel.org,
 Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org,
 John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <Felix.Kuehling@amd.com>,
 =?utf-8?b?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>,
 Jason Gunthorpe <jgg@mellanox.com>, Ross Zwisler <zwisler@kernel.org>,
 linux-fsdevel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 =?utf-8?q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
 <20190123222315.1122-9-jglisse@redhat.com>
 <154833175216.4120.925061299171157938@jlahtine-desk.ger.corp.intel.com>
 <20190124153032.GA5030@redhat.com>
Message-ID: <154877159986.4387.16328989441685542244@jlahtine-desk.ger.corp.intel.com>
User-Agent: alot/0.6
Subject: Re: [PATCH v4 8/9] gpu/drm/i915: optimize out the case when a range is
 updated to read only
Date: Tue, 29 Jan 2019 16:20:00 +0200
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Jerome Glisse (2019-01-24 17:30:32)
> On Thu, Jan 24, 2019 at 02:09:12PM +0200, Joonas Lahtinen wrote:
> > Hi Jerome,
> > =

> > This patch seems to have plenty of Cc:s, but none of the right ones :)
> =

> So sorry, i am bad with git commands.
> =

> > For further iterations, I guess you could use git option --cc to make
> > sure everyone gets the whole series, and still keep the Cc:s in the
> > patches themselves relevant to subsystems.
> =

> Will do.
> =

> > This doesn't seem to be on top of drm-tip, but on top of your previous
> > patches(?) that I had some comments about. Could you take a moment to
> > first address the couple of question I had, before proceeding to discuss
> > what is built on top of that base.
> =

> It is on top of Linus tree so roughly ~ rc3 it does not depend on any
> of the previous patch i posted.

You actually managed to race a point in time just when Chris rewrote much
of the userptr code in drm-tip, which I didn't remember of. My bad.

Still interested to hearing replies to my questions in the previous
thread, if the series is still relevant. Trying to get my head around
how the different aspects of HMM pan out for devices without fault handling.

> I still intended to propose to remove
> GUP from i915 once i get around to implement the equivalent of GUP_fast
> for HMM and other bonus cookies with it.
> =

> The plan is once i have all mm bits properly upstream then i can propose
> patches to individual driver against the proper driver tree ie following
> rules of each individual device driver sub-system and Cc only people
> there to avoid spamming the mm folks :)

Makes sense, as we're having tons of changes in this field in i915, the
churn to rebase on top of them will be substantial.

Regards, Joonas

PS. Are you by any chance attending FOSDEM? Would be nice to chat about
this.

> =

> =

> > =

> > My reply's Message-ID is:
> > 154289518994.19402.3481838548028068213@jlahtine-desk.ger.corp.intel.com
> > =

> > Regards, Joonas
> > =

> > PS. Please keep me Cc:d in the following patches, I'm keen on
> > understanding the motive and benefits.
> > =

> > Quoting jglisse@redhat.com (2019-01-24 00:23:14)
> > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > > =

> > > When range of virtual address is updated read only and corresponding
> > > user ptr object are already read only it is pointless to do anything.
> > > Optimize this case out.
> > > =

> > > Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > > Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> > > Cc: Jan Kara <jack@suse.cz>
> > > Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> > > Cc: Jason Gunthorpe <jgg@mellanox.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Matthew Wilcox <mawilcox@microsoft.com>
> > > Cc: Ross Zwisler <zwisler@kernel.org>
> > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > Cc: Paolo Bonzini <pbonzini@redhat.com>
> > > Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > Cc: kvm@vger.kernel.org
> > > Cc: dri-devel@lists.freedesktop.org
> > > Cc: linux-rdma@vger.kernel.org
> > > Cc: linux-fsdevel@vger.kernel.org
> > > Cc: Arnd Bergmann <arnd@arndb.de>
> > > ---
> > >  drivers/gpu/drm/i915/i915_gem_userptr.c | 16 ++++++++++++++++
> > >  1 file changed, 16 insertions(+)
> > > =

> > > diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/dr=
m/i915/i915_gem_userptr.c
> > > index 9558582c105e..23330ac3d7ea 100644
> > > --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> > > +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> > > @@ -59,6 +59,7 @@ struct i915_mmu_object {
> > >         struct interval_tree_node it;
> > >         struct list_head link;
> > >         struct work_struct work;
> > > +       bool read_only;
> > >         bool attached;
> > >  };
> > >  =

> > > @@ -119,6 +120,7 @@ static int i915_gem_userptr_mn_invalidate_range_s=
tart(struct mmu_notifier *_mn,
> > >                 container_of(_mn, struct i915_mmu_notifier, mn);
> > >         struct i915_mmu_object *mo;
> > >         struct interval_tree_node *it;
> > > +       bool update_to_read_only;
> > >         LIST_HEAD(cancelled);
> > >         unsigned long end;
> > >  =

> > > @@ -128,6 +130,8 @@ static int i915_gem_userptr_mn_invalidate_range_s=
tart(struct mmu_notifier *_mn,
> > >         /* interval ranges are inclusive, but invalidate range is exc=
lusive */
> > >         end =3D range->end - 1;
> > >  =

> > > +       update_to_read_only =3D mmu_notifier_range_update_to_read_onl=
y(range);
> > > +
> > >         spin_lock(&mn->lock);
> > >         it =3D interval_tree_iter_first(&mn->objects, range->start, e=
nd);
> > >         while (it) {
> > > @@ -145,6 +149,17 @@ static int i915_gem_userptr_mn_invalidate_range_=
start(struct mmu_notifier *_mn,
> > >                  * object if it is not in the process of being destro=
yed.
> > >                  */
> > >                 mo =3D container_of(it, struct i915_mmu_object, it);
> > > +
> > > +               /*
> > > +                * If it is already read only and we are updating to
> > > +                * read only then we do not need to change anything.
> > > +                * So save time and skip this one.
> > > +                */
> > > +               if (update_to_read_only && mo->read_only) {
> > > +                       it =3D interval_tree_iter_next(it, range->sta=
rt, end);
> > > +                       continue;
> > > +               }
> > > +
> > >                 if (kref_get_unless_zero(&mo->obj->base.refcount))
> > >                         queue_work(mn->wq, &mo->work);
> > >  =

> > > @@ -270,6 +285,7 @@ i915_gem_userptr_init__mmu_notifier(struct drm_i9=
15_gem_object *obj,
> > >         mo->mn =3D mn;
> > >         mo->obj =3D obj;
> > >         mo->it.start =3D obj->userptr.ptr;
> > > +       mo->read_only =3D i915_gem_object_is_readonly(obj);
> > >         mo->it.last =3D obj->userptr.ptr + obj->base.size - 1;
> > >         INIT_WORK(&mo->work, cancel_userptr);
> > >  =

> > > -- =

> > > 2.17.2
> > > =

> > > _______________________________________________
> > > dri-devel mailing list
> > > dri-devel@lists.freedesktop.org
> > > https://lists.freedesktop.org/mailman/listinfo/dri-devel

