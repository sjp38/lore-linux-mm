Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72019C46477
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:42:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2642A206E0
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:42:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="zfGP+t+9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2642A206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7AD76B0010; Wed, 12 Jun 2019 14:42:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2ABD6B0266; Wed, 12 Jun 2019 14:42:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A412F6B0269; Wed, 12 Jun 2019 14:42:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9C06B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:42:06 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id p7so8126345otk.22
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:42:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=tLkmphJnLjEku4wPa26GqmShS2e5likwCcmpQlFLS9E=;
        b=VEybjlP4riwrKAYj7ZyUNnLoTisYDBLfmGSfq9BFGl7DTD53kcLvO2GzDEDrszx4sR
         PKDQVvKZ0zObyGVBlCtT3gjifCg6bLTZrd2q0xICotkZbzb2kETdVkS16PFecs0TJRuA
         +Og6Y/LQJQn8AuJ29X8X/kZatYMNSvaIVMZCVW7lVdBUkF7CodTK/0+2Jku6DL5oMSLI
         SVf6W4qGyKFRczdsCKRefpRTWNWSRIMMzNN4zS1R+xswfELhx/X6afhJvB0UL4CCRK9W
         rjR0glKeApENLoQRXq1Oz5hN6+29dEPfe/GE26F3Ezet+jq/ohHEfFtIpDs/tW4G+7w3
         sFgw==
X-Gm-Message-State: APjAAAXkMydAUTGrPRM/t2aKBhGJMyiDMPnPEPOiMWSeeqI4IqyYGwVl
	Rw8Z8ClsY18MpcLJBViEF/96v8d8/8fZWzAyBuDOLTc/j+QRHTYPk0kFgz8gqEp3AiEaXqxABIr
	Aj/PnI8MhkZMYQUhnsJhtzAroMWLU0kR1aBSG3Thq3DiWs19AQ60QdutCc+P3GT3VEw==
X-Received: by 2002:aca:35c4:: with SMTP id c187mr448661oia.72.1560364926065;
        Wed, 12 Jun 2019 11:42:06 -0700 (PDT)
X-Received: by 2002:aca:35c4:: with SMTP id c187mr448628oia.72.1560364925412;
        Wed, 12 Jun 2019 11:42:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560364925; cv=none;
        d=google.com; s=arc-20160816;
        b=cVD0o/hnwr4bNfc4hWLuw5IiDlw37gSLqPjZrY6QSNcdSBSIViSM+93gkFHabye2lx
         mcClX5bL2tXjGWQMsyowyCHTwhn4e8pcyWh3XfBU7kJsyMLINqhOTr+juoyXH9AN3Vg6
         UN/9EpqlQVVTe8ko5EvI4o1Jo6KuN6+/7NkOb4y4NQxn2TVVNnsFhoM1DfebEWsIuc61
         xiCG1YctfzHcFRYdEeaPf+Lop/M4ojlT/RHtxVEEIdKcanfsTWZ9FrGU8wvVc5C+yyov
         9SF3iX2/VEcgWKJF2ExwGZY/zT6v5JVCoXuojAsqzwU09GKUTx/qQdZXe1TqxwY1qUFl
         pWFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=tLkmphJnLjEku4wPa26GqmShS2e5likwCcmpQlFLS9E=;
        b=CU0FAa8xRnM7XW+UuGNmIyVtUG1SBn+oCHck25RteHVw2ZdehefDb0NLHu/TnXuwaI
         RoeUpz1o4Ss0WS7/snYjOCqkj7FpZgFZRkesH4qBdAf8i514tSbgvFDt5oRLe9lNjWhD
         /AH8epXGoUN/OClz5qHbHhV14JIN8mCTKd/Ztq8I3DdBa5rmc6L3CAZDaLZKCF4qpOEN
         FXYRsljc4/GEmvATKIczPubS+WaJ6pMHWUr+LWYh5CuQlk07B4sGeDCSOwBQOy3hzQBO
         LIzTTrjMEvC2T+agp6rcB2jGkR9z/cAJlidtvh/ZgZWMgEsFvcmNO9oG4eX7rUBYEflw
         zoTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=zfGP+t+9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k203sor386390oih.104.2019.06.12.11.42.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 11:42:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=zfGP+t+9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=tLkmphJnLjEku4wPa26GqmShS2e5likwCcmpQlFLS9E=;
        b=zfGP+t+9ivTiw9crHzyoG37UKVT39+ZjMSRc6i4RLF5qzgoEzM0PJJFpTl3UpomLM/
         kX7wxsRh/bfXL05Kn2SjQT8PDTQbpZvw2lUD2P17lgifKk9462SiGOzy9eolZxENP8tF
         +j8h3CL4xbOvN0NcXJng0ZhfijbK4zlpWlo5g45OKeiNBbSWh4j6EO8XjD4uzxYBWXSc
         XQXw6jfUAUrXoISJcc1nasZDsCw2vNnJrgvivK5m8U97df7yj+O0/KKRytyMUK2vV5wL
         CVPInnibqz35AZHLe+QENPOC6d6PXPPLQ6FBHTljTMKMRhnltIiFojDH2RTb0H3+DeCQ
         awHA==
X-Google-Smtp-Source: APXvYqxw8Jxg8VjrdgkzfIw+Yn35hC16YxwrfmO4tE9KRMFgYTyKNK9pqaozSKJ82RqVYk9X5Uls8HWSSM7jkwOY/uo=
X-Received: by 2002:aca:ed4c:: with SMTP id l73mr412323oih.149.1560364924898;
 Wed, 12 Jun 2019 11:42:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190606014544.8339-1-ira.weiny@intel.com> <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca> <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz> <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com> <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca> <20190612120907.GC14578@quack2.suse.cz>
In-Reply-To: <20190612120907.GC14578@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Jun 2019 11:41:53 -0700
Message-ID: <CAPcyv4ikn219XUgHwsPdYp06vBNAJB9Rk-hjZA-fYT4GB3gi+w@mail.gmail.com>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
To: Jan Kara <jack@suse.cz>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Ira Weiny <ira.weiny@intel.com>, "Theodore Ts'o" <tytso@mit.edu>, 
	Jeff Layton <jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, linux-xfs <linux-xfs@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-ext4 <linux-ext4@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 5:09 AM Jan Kara <jack@suse.cz> wrote:
>
> On Wed 12-06-19 08:47:21, Jason Gunthorpe wrote:
> > On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:
> >
> > > > > The main objection to the current ODP & DAX solution is that very
> > > > > little HW can actually implement it, having the alternative still
> > > > > require HW support doesn't seem like progress.
> > > > >
> > > > > I think we will eventually start seein some HW be able to do this
> > > > > invalidation, but it won't be universal, and I'd rather leave it
> > > > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > > > on fire, I need to unplug it).
> > > >
> > > > Agreed.  I think software wise there is not much some of the devices can do
> > > > with such an "invalidate".
> > >
> > > So out of curiosity: What does RDMA driver do when userspace just closes
> > > the file pointing to RDMA object? It has to handle that somehow by aborting
> > > everything that's going on... And I wanted similar behavior here.
> >
> > It aborts *everything* connected to that file descriptor. Destroying
> > everything avoids creating inconsistencies that destroying a subset
> > would create.
> >
> > What has been talked about for lease break is not destroying anything
> > but very selectively saying that one memory region linked to the GUP
> > is no longer functional.
>
> OK, so what I had in mind was that if RDMA app doesn't play by the rules
> and closes the file with existing pins (and thus layout lease) we would
> force it to abort everything. Yes, it is disruptive but then the app didn't
> obey the rule that it has to maintain file lease while holding pins. Thus
> such situation should never happen unless the app is malicious / buggy.

When you say 'close' do you mean the final release of the fd? The vma
keeps a reference to a 'struct file' live even after the fd is closed.

