Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EAEDC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D021E2184B
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:53:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="mNXBi6fQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D021E2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DDDC6B0005; Wed, 17 Apr 2019 17:53:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48C836B0006; Wed, 17 Apr 2019 17:53:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37AE26B0007; Wed, 17 Apr 2019 17:53:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B39F6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:53:42 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id r190so4436oie.13
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:53:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=bmWs4cfcbPpVqJOif+pRxG1XcZMU7gy3yov8rwtSMcA=;
        b=nv74GlNVoYt79DkHJE0MxFmwt3sor5EeK7io8UideewnjjwF5sgjb7QuhRSpyNYmhQ
         3OqTbjELOqsByt4XcIgAZGwEQr2MR89ZrVRJhTTNCt7fsonSqOySII/5Y0GA7aX0gcNL
         EPQ4bVy3LT1jID5Xqcn/ga1TW5lYEVBXC+mqitoEmHWyFOeakhchdcU6foM4llQkD/69
         wSoJ0uwBb8j35P3WfSU9FxhbUQoLHm7KrwLgMjiQWieG89iQ2qNKEpcJFiuu1cmNy3oe
         PW+Ox2gqzYjxD8huGozFpnlW0V87Sdmly/3Qj8dB0mVZtJaHesQFb+Rc2KgYdjWhTr3w
         lNKQ==
X-Gm-Message-State: APjAAAUzsukRxtjdu4EPhF+Nfxqqr+GExhFL3UnpiqPtKRdpu1GsbMsz
	ixY4HCpH7nFqXkyqNxUerxoGnc62c/I68VCbgdrxI8eXoM2AoRld6g6YF4ekKIBfLJDVrMaNMNk
	j985jJZDZdV/KzlYymCr7iA16wBHdPHIV8viDQDLv9VM5K9xDeXhwPSxQze2Jm3mfIA==
X-Received: by 2002:a9d:74d6:: with SMTP id a22mr51084811otl.336.1555538021572;
        Wed, 17 Apr 2019 14:53:41 -0700 (PDT)
X-Received: by 2002:a9d:74d6:: with SMTP id a22mr51084746otl.336.1555538020412;
        Wed, 17 Apr 2019 14:53:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538020; cv=none;
        d=google.com; s=arc-20160816;
        b=BlgswBZZakLzID9aTqY27WtkJbWTn7ZyZu022YxnQHRqbnSEgPl40R5CEUzoEZKoXf
         0fThJMgXF5s7biYvdGLLNey7dM4e0ugXJ3S77JEmVwDapp87HUuveoUU+pJnFlJHzwF9
         HIwSPaRP9UJWW+ETGu6bRZrJH6nEAseRnt7HEp+RG3i73mvsR7WDDZLrnAjuTN4SaOms
         XTDz9BLrHoA02sDTspQ8kx1r2PmGDEtxELwdnr80YR1+nJgei6mETqk3jEiGAfNlKM75
         X8Melnt+g/GnRkGodrQbN+uHEDvwjKK4e0JwkWeEuQqSORrYBe0B8HYYnsLkeCTnVcRQ
         hiYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=bmWs4cfcbPpVqJOif+pRxG1XcZMU7gy3yov8rwtSMcA=;
        b=FfyjnZlk6y4jO4vJhobHY6dcuRvmhu4iBl1zb4iMm3NSow/7V0sJnjWO1GSHaEilbZ
         UVcPKH3XL4Ifsr6d6zC709P1CrC/WWWtBWh1HKiKoGmWiF6HdOIA85ujvTAX+oJAfUIc
         gSKIDd0Ysc//lcDfWNIp6eIAV2uMWHGLL9vmDFohJYKhvtcApbyiLhjpgfVJ/smM7JDN
         HSFjDVYO9zk4KCXfcCVvxHDbf7NgpagtBJA9k+/uTXFySLWIcEriJWj/Xc1XkwKlAcR7
         iCoOXuWOjMdrnoUGeq96Cri2O59bohAxCt8LgZ84cbUZN9dRnPpA5z5TIjD6QNWjVYmh
         hlCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=mNXBi6fQ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e19sor41802oib.13.2019.04.17.14.53.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 14:53:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=mNXBi6fQ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=bmWs4cfcbPpVqJOif+pRxG1XcZMU7gy3yov8rwtSMcA=;
        b=mNXBi6fQESbyNgWoPJY7N13rwrd4xj6HYS5Lh3w1uIDtpX1jEKuq/1CY0sXLMgffyd
         8fZ6OewqjPjD5p1dwCTsSN1W1JI3+mAdGAgxxXw75SBC6d+ViIpSkPHWX5e5RJagZjvQ
         yjyjDElcbDvHNl9O5W+P579YMN+Hj4U+LrEN+x8Tx6zusmLLB4Z4jJcmnJV1+UsdIb3F
         1jz7zS/16yvMO624WsnVUtKXz4hREDASy23Mdu0AVjgHo/MQiqVzCTWgdALrvHGuAXsn
         Ga4vq1ZdMjyFyMjjBa4qxfrflIh+TF3ZFVeRDTP9cYV0z9LNe75WG0zQVSvJDsu+rJAK
         ZpTw==
X-Google-Smtp-Source: APXvYqyIfM8qxAG0J70YozmGmBKyUMmNKkQ53mBEzGEECW5CLl3/GymyVafAOCfvYgHDugLDiei1oDZqZT6jsakABBE=
X-Received: by 2002:aca:e64f:: with SMTP id d76mr587154oih.105.1555538019809;
 Wed, 17 Apr 2019 14:53:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190411210834.4105-1-jglisse@redhat.com> <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel> <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <20190416194936.GD21526@redhat.com>
In-Reply-To: <20190416194936.GD21526@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 17 Apr 2019 14:53:28 -0700
Message-ID: <CAPcyv4i-YHH+dH8za1i1aMcHzQXfovVSrRFp_nfa-KYN-XhAvw@mail.gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
To: Jerome Glisse <jglisse@redhat.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>, Boaz Harrosh <boaz@plexistor.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, 
	Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Thumshirn <jthumshirn@suse.de>, 
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, Steve French <sfrench@samba.org>, 
	linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, 
	Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, 
	Alex Elder <elder@kernel.org>, ceph-devel@vger.kernel.org, 
	Eric Van Hensbergen <ericvh@gmail.com>, Latchesar Ionkov <lucho@ionkov.net>, Mike Marshall <hubcap@omnibond.com>, 
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, 
	Dominique Martinet <asmadeus@codewreck.org>, v9fs-developer@lists.sourceforge.net, 
	Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, 
	=?UTF-8?Q?Ernesto_A=2E_Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 12:50 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Tue, Apr 16, 2019 at 12:12:27PM -0700, Dan Williams wrote:
> > On Tue, Apr 16, 2019 at 11:59 AM Kent Overstreet
> > <kent.overstreet@gmail.com> wrote:
> > >
> > > On Tue, Apr 16, 2019 at 09:35:04PM +0300, Boaz Harrosh wrote:
> > > > On Thu, Apr 11, 2019 at 05:08:19PM -0400, jglisse@redhat.com wrote:
> > > > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > > > >
> > > > > This patchset depends on various small fixes [1] and also on patc=
hset
> > > > > which introduce put_user_page*() [2] and thus is 5.3 material as =
those
> > > > > pre-requisite will get in 5.2 at best. Nonetheless i am posting i=
t now
> > > > > so that it can get review and comments on how and what should be =
done
> > > > > to test things.
> > > > >
> > > > > For various reasons [2] [3] we want to track page reference throu=
gh GUP
> > > > > differently than "regular" page reference. Thus we need to keep t=
rack
> > > > > of how we got a page within the block and fs layer. To do so this=
 patch-
> > > > > set change the bio_bvec struct to store a pfn and flags instead o=
f a
> > > > > direct pointer to a page. This way we can flag page that are comi=
ng from
> > > > > GUP.
> > > > >
> > > > > This patchset is divided as follow:
> > > > >     - First part of the patchset is just small cleanup i believe =
they
> > > > >       can go in as his assuming people are ok with them.
> > > >
> > > >
> > > > >     - Second part convert bio_vec->bv_page to bio_vec->bv_pfn thi=
s is
> > > > >       done in multi-step, first we replace all direct dereference=
 of
> > > > >       the field by call to inline helper, then we introduce macro=
 for
> > > > >       bio_bvec that are initialized on the stack. Finaly we chang=
e the
> > > > >       bv_page field to bv_pfn.
> > > >
> > > > Why do we need a bv_pfn. Why not just use the lowest bit of the pag=
e-ptr
> > > > as a flag (pointer always aligned to 64 bytes in our case).
> > > >
> > > > So yes we need an inline helper for reference of the page but is it=
 not clearer
> > > > that we assume a page* and not any kind of pfn ?
> > > > It will not be the first place using low bits of a pointer for flag=
s.
> > > >
> > > > That said. Why we need it at all? I mean why not have it as a bio f=
lag. If it exist
> > > > at all that a user has a GUP and none-GUP pages to IO at the same r=
equest he/she
> > > > can just submit them as two separate BIOs (chained at the block lay=
er).
> > > >
> > > > Many users just submit one page bios and let elevator merge them an=
y way.
> > >
> > > Let's please not add additional flags and weirdness to struct bio - "=
if this
> > > flag is set interpret one way, if not interpret another" - or eventua=
lly bios
> > > will be as bad as skbuffs. I would much prefer just changing bv_page =
to bv_pfn.
> >
> > This all reminds of the failed attempt to teach the block layer to
> > operate without pages:
> >
> > https://lore.kernel.org/lkml/20150316201640.33102.33761.stgit@dwillia2-=
desk3.amr.corp.intel.com/
> >
> > >
> > > Question though - why do we need a flag for whether a page is a GUP p=
age or not?
> > > Couldn't the needed information just be determined by what range the =
pfn is not
> > > (i.e. whether or not it has a struct page associated with it)?
> >
> > That amounts to a pfn_valid() check which is a bit heavier than if we
> > can store a flag in the bv_pfn entry directly.
> >
> > I'd say create a new PFN_* flag, and make bv_pfn a 'pfn_t' rather than
> > an 'unsigned long'.
> >
> > That said, I'm still in favor of Jan's proposal to just make the
> > bv_page semantics uniform. Otherwise we're complicating this core
> > infrastructure for some yet to be implemented GPU memory management
> > capabilities with yet to be determined value. Circle back when that
> > value is clear, but in the meantime fix the GUP bug.
>
> This has nothing to do with GPU, what make you think so ? Here i am
> trying to solve GUP and to keep the value of knowing wether a page
> has been GUP or not. I argue that if we bias every page in every bio
> then we loose that information and thus the value.
>
> I gave the page protection mechanisms as an example that would be
> impacted but it is not the only one. Knowing if a page has been GUP
> can be useful for memory reclaimation, compaction, NUMA balancing,

Right, this is what I was reacting to in your pushback to Jan's
proposal. You're claiming value for not doing the simple thing for
some future "may be useful in these contexts". To my knowledge those
things are not broken today. You're asking for the complexity to be
carried today for some future benefit, and I'm asking for the
simplicity to be maintained as much as possible today and let the
value of future changes stand on their own to push for more complexity
later.

Effectively don't use this bug fix to push complexity for a future
agenda where the value has yet to be quantified.

