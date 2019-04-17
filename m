Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABEEDC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 23:32:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3219E218CD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 23:32:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="cdeV5Co7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3219E218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A392F6B0005; Wed, 17 Apr 2019 19:32:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E8596B0006; Wed, 17 Apr 2019 19:32:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FDAA6B0007; Wed, 17 Apr 2019 19:32:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66C3B6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 19:32:33 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id i203so104695oih.16
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 16:32:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=WUa9a+RBmWkNHf5y3SQh7mLUba+umXWQDwj4aTSk0ls=;
        b=SiYa4UV2cbmlkk+C7IypGauTyt5Tct8f1b9VOmpcrqjinxpbeVyooCJ3rrK3YxPmEz
         9+jZeaw52CitenMNa+WefeiEVEfRz6FSLLnPBNEFduInWxKZ1v6ELx5InPuIu9RisI3v
         h8krGKV3mW9yqpuNAgLZ9yHhKs8/x/0xZET2YtAsgYyCHhi3CYZ827qnRzi61iGPuM0A
         C4sLrN24Fw4rWVRHqgi2wXvO3PYdaF1Ficy4CGyA1B8gIvGnaKNGcK2kGW/KxmYA+abH
         IqnAuNfCBXa5lQaSTklbsAU0vCR06eyW0m4YvO7ooSQoiy+Kk5mx91jx8csNBI/35Wsx
         Z3nQ==
X-Gm-Message-State: APjAAAWwZEsOCLqrEfA4Xw7KcIPTI5v4+9yHiVi4YGl2AWIrf9sQ/+UF
	5mCUzlpIZGUOqwerSdu9G517XZSemo8H3x9y8kNbs0UXNVo2K8Ec8npdzIq9cQumaIwhGpjEn+i
	hwZ2jeufB+u9+IfgotQ1rIDDyUsh4SPXaTgAYattbeMorC+w4eQunfhVIUEUCzubqPQ==
X-Received: by 2002:a05:6830:2009:: with SMTP id e9mr58712369otp.142.1555543953039;
        Wed, 17 Apr 2019 16:32:33 -0700 (PDT)
X-Received: by 2002:a05:6830:2009:: with SMTP id e9mr58712298otp.142.1555543951708;
        Wed, 17 Apr 2019 16:32:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555543951; cv=none;
        d=google.com; s=arc-20160816;
        b=cGRwaPiWrQc6L2I6YWOQTdeyadlOpdCQas8X/P8SQv2uw6ObPBqrAb84VDCxTeg4xy
         Bj739f9FeRM2kWltwkadK4aSnoQgyTU2vx2rfKsvLDa94dlyISb3XmHOAdG7RKMPwa8G
         IyeOzBbss1tcFC72or1ERUtQQ+Z1IUa5iQpq0inWhoh1UkJ2pfvxwqALU/cun/1BtUlm
         IDB9cGKA66ezL0frHJusSp1WfWQh2LLCK1ar+d2j6SHI5Bk/RuMdlkCNWHwuW2o4t5PU
         OiiHIN7eGqNEEoBB3zd6syIMeLKowws8HGfwfd+Webq6Fd/pVvc4nipA1SPNRGEnJRhW
         bfww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=WUa9a+RBmWkNHf5y3SQh7mLUba+umXWQDwj4aTSk0ls=;
        b=tWcYeyd/Rzmyi7HF0lOYWAWC5P/KVNXH3dABHR/NjcKZq8onJFvgC7wkUFPY3O1aet
         bjGb2ypSQ3Yjhx0e2hfiwP/OAOUurou7J/NcUoEalG4lqG0nvUlQaSiXb2eMLBIFQ4hw
         oqwOu+e2q5VpaKWyRy0foZu2QXRZkS/DruTHt3Smzvd54g1N1qy4AyadmYUygOn7jntz
         clUSzF9Lhh7E+PBTB2S2ihAaDeEnKj2P4gqiQ/sDG/S+b4R1dXXfrr0CrU8/pf5JxwhL
         KrKr6SqHe2GvHDi75KhuT1Sz38Nrqy9dbjprX0eFj48mdGzNFHeai8BfdnwL8VX/OW38
         GGVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=cdeV5Co7;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i125sor134193oif.64.2019.04.17.16.32.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 16:32:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=cdeV5Co7;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=WUa9a+RBmWkNHf5y3SQh7mLUba+umXWQDwj4aTSk0ls=;
        b=cdeV5Co7FAIJCJ2uthEYHgkj7jQNxGzx7ep9TxpYX5XjNACqdOXejoY266/1dBGT5M
         HnOS3LX5PyUx96RYsO78EGPeUYXbdW74e5bDa8sZ5vVxuHLUqmrt7d1lOuoWCBHWGzy8
         xuY1jwqv3CaVJICAqpnL8lY6WUDfMYs2rB06UznxAPbAxe/HLtMac3hWxZ5Lnpu+DD2P
         FfSD0YdX/bwEj7E0mFYdVg825B6LZR777NjVV7BkfTHFkmP0P5WxTahHPOMEXjKUg6Ni
         BwMDTzHGtAb9IyFMr4Qaq9rMED9Qtj8WcU2oFxPFFxXV9Yd6HzUyKqvSRbYw9OGlGYjD
         zNcQ==
X-Google-Smtp-Source: APXvYqxbYEcI7nDGR81hG8KpBIqWV+qkrRq7k1+Hbw9zZA5mDoWe6Sbms3neiEWQu/uX94yQ5kYig9QFQfhwENdENQ8=
X-Received: by 2002:aca:ed88:: with SMTP id l130mr99825oih.70.1555543951170;
 Wed, 17 Apr 2019 16:32:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190411210834.4105-1-jglisse@redhat.com> <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel> <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <20190416194936.GD21526@redhat.com> <CAPcyv4i-YHH+dH8za1i1aMcHzQXfovVSrRFp_nfa-KYN-XhAvw@mail.gmail.com>
 <20190417222858.GA4146@redhat.com>
In-Reply-To: <20190417222858.GA4146@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 17 Apr 2019 16:32:19 -0700
Message-ID: <CAPcyv4h8Wfy_ry54NOCeFGncwDPCfizpsntbD-w+E11fuf13zQ@mail.gmail.com>
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

On Wed, Apr 17, 2019 at 3:29 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Wed, Apr 17, 2019 at 02:53:28PM -0700, Dan Williams wrote:
> > On Tue, Apr 16, 2019 at 12:50 PM Jerome Glisse <jglisse@redhat.com> wro=
te:
> > >
> > > On Tue, Apr 16, 2019 at 12:12:27PM -0700, Dan Williams wrote:
> > > > On Tue, Apr 16, 2019 at 11:59 AM Kent Overstreet
> > > > <kent.overstreet@gmail.com> wrote:
> > > > >
> > > > > On Tue, Apr 16, 2019 at 09:35:04PM +0300, Boaz Harrosh wrote:
> > > > > > On Thu, Apr 11, 2019 at 05:08:19PM -0400, jglisse@redhat.com wr=
ote:
> > > > > > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > > > > > >
> > > > > > > This patchset depends on various small fixes [1] and also on =
patchset
> > > > > > > which introduce put_user_page*() [2] and thus is 5.3 material=
 as those
> > > > > > > pre-requisite will get in 5.2 at best. Nonetheless i am posti=
ng it now
> > > > > > > so that it can get review and comments on how and what should=
 be done
> > > > > > > to test things.
> > > > > > >
> > > > > > > For various reasons [2] [3] we want to track page reference t=
hrough GUP
> > > > > > > differently than "regular" page reference. Thus we need to ke=
ep track
> > > > > > > of how we got a page within the block and fs layer. To do so =
this patch-
> > > > > > > set change the bio_bvec struct to store a pfn and flags inste=
ad of a
> > > > > > > direct pointer to a page. This way we can flag page that are =
coming from
> > > > > > > GUP.
> > > > > > >
> > > > > > > This patchset is divided as follow:
> > > > > > >     - First part of the patchset is just small cleanup i beli=
eve they
> > > > > > >       can go in as his assuming people are ok with them.
> > > > > >
> > > > > >
> > > > > > >     - Second part convert bio_vec->bv_page to bio_vec->bv_pfn=
 this is
> > > > > > >       done in multi-step, first we replace all direct derefer=
ence of
> > > > > > >       the field by call to inline helper, then we introduce m=
acro for
> > > > > > >       bio_bvec that are initialized on the stack. Finaly we c=
hange the
> > > > > > >       bv_page field to bv_pfn.
> > > > > >
> > > > > > Why do we need a bv_pfn. Why not just use the lowest bit of the=
 page-ptr
> > > > > > as a flag (pointer always aligned to 64 bytes in our case).
> > > > > >
> > > > > > So yes we need an inline helper for reference of the page but i=
s it not clearer
> > > > > > that we assume a page* and not any kind of pfn ?
> > > > > > It will not be the first place using low bits of a pointer for =
flags.
> > > > > >
> > > > > > That said. Why we need it at all? I mean why not have it as a b=
io flag. If it exist
> > > > > > at all that a user has a GUP and none-GUP pages to IO at the sa=
me request he/she
> > > > > > can just submit them as two separate BIOs (chained at the block=
 layer).
> > > > > >
> > > > > > Many users just submit one page bios and let elevator merge the=
m any way.
> > > > >
> > > > > Let's please not add additional flags and weirdness to struct bio=
 - "if this
> > > > > flag is set interpret one way, if not interpret another" - or eve=
ntually bios
> > > > > will be as bad as skbuffs. I would much prefer just changing bv_p=
age to bv_pfn.
> > > >
> > > > This all reminds of the failed attempt to teach the block layer to
> > > > operate without pages:
> > > >
> > > > https://lore.kernel.org/lkml/20150316201640.33102.33761.stgit@dwill=
ia2-desk3.amr.corp.intel.com/
> > > >
> > > > >
> > > > > Question though - why do we need a flag for whether a page is a G=
UP page or not?
> > > > > Couldn't the needed information just be determined by what range =
the pfn is not
> > > > > (i.e. whether or not it has a struct page associated with it)?
> > > >
> > > > That amounts to a pfn_valid() check which is a bit heavier than if =
we
> > > > can store a flag in the bv_pfn entry directly.
> > > >
> > > > I'd say create a new PFN_* flag, and make bv_pfn a 'pfn_t' rather t=
han
> > > > an 'unsigned long'.
> > > >
> > > > That said, I'm still in favor of Jan's proposal to just make the
> > > > bv_page semantics uniform. Otherwise we're complicating this core
> > > > infrastructure for some yet to be implemented GPU memory management
> > > > capabilities with yet to be determined value. Circle back when that
> > > > value is clear, but in the meantime fix the GUP bug.
> > >
> > > This has nothing to do with GPU, what make you think so ? Here i am
> > > trying to solve GUP and to keep the value of knowing wether a page
> > > has been GUP or not. I argue that if we bias every page in every bio
> > > then we loose that information and thus the value.
> > >
> > > I gave the page protection mechanisms as an example that would be
> > > impacted but it is not the only one. Knowing if a page has been GUP
> > > can be useful for memory reclaimation, compaction, NUMA balancing,
> >
> > Right, this is what I was reacting to in your pushback to Jan's
> > proposal. You're claiming value for not doing the simple thing for
> > some future "may be useful in these contexts". To my knowledge those
> > things are not broken today. You're asking for the complexity to be
> > carried today for some future benefit, and I'm asking for the
> > simplicity to be maintained as much as possible today and let the
> > value of future changes stand on their own to push for more complexity
> > later.
> >
> > Effectively don't use this bug fix to push complexity for a future
> > agenda where the value has yet to be quantified.
>
> Except that this solution (biasing everyone in bio) would _more complex_
> it is only conceptualy appealing. The changes are on the other hand much
> deeper and much riskier but you decided to ignore that and focus on some-
> thing i was just giving as an example.

Not ignoring, asking for more clarification on the complexity it
introduces independent of potential future uses.

