Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67848C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:50:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ED13215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:50:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="gmeYon7z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ED13215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B266D6B0010; Wed, 12 Jun 2019 14:50:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD7666B0266; Wed, 12 Jun 2019 14:50:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C5276B0269; Wed, 12 Jun 2019 14:50:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F72C6B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:50:04 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id b64so8156423otc.3
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:50:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oLKBk3Q7ccO0NJJMRJYYFBU09UJHS0/ornRP0j3Fxnk=;
        b=aHlOIj0sd6yhuT+6zGVRR5GDImozb8+MwCIyFXvn5mCHLSjbfLHn1s2V/EPhC2daz8
         wGzboXg+Lj3+vFIE8d/s+WviF4IRAyNhq1RnbNwuDO61op5SUllrOtZDGBo6Mjo6CGFl
         O+Y39a+IEJNbWcyPLg2VRJ/wQhiYgUaMQDjsypi9U+9Cxmf0MkNWz9bdUrxdYCpFfgXF
         360f2+bkF+ZM5Lii4aUCRgiwFWhrIeahRaxIangmC25kt59aoTQgS1RgboeNkVXOjXS8
         pEL6Hzdrfaybs/hVehzjI36U1u+KFEN9YUXAVCkgZ1+pNvROY7wQ3zMbkHvXYIAtReQa
         0O+A==
X-Gm-Message-State: APjAAAVVVqfmy+YvPKjl6Mwjs9sRWEqHvWGFaRQpX+Qxh9WdUgciRkVC
	zekB1PXe2FoyQhJWjEvcxZN6V7T5N9xkZ5ZESYfAUCNm06DI7Tz8X0BiDfMzmVaVaXbN9ylWSkK
	yvnYF+ezWYdDwkKVeM46T29WKGN0gjlnjYvXBrOLl+tHkjVCXSXA17SWhk07W6BHxKQ==
X-Received: by 2002:a9d:3c5:: with SMTP id f63mr5162541otf.210.1560365404142;
        Wed, 12 Jun 2019 11:50:04 -0700 (PDT)
X-Received: by 2002:a9d:3c5:: with SMTP id f63mr5162492otf.210.1560365403324;
        Wed, 12 Jun 2019 11:50:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560365403; cv=none;
        d=google.com; s=arc-20160816;
        b=KbAOJ/Ynj2mCgbU9B6bR7UGoNJmQdKQw/jE+EAgiTBT/BNTxQf73jeILNp0X1jpFvF
         lc/UJ39mm797jW+hJ6hicXabGo9VKtqt57ohtlOHDS5gz+RA+8Ir+tjTIFX9h1tR9Ck6
         bTfCHb9Wh+RSzvJyfN2Bz/GfGfLcWiNQ91JZPtMXAOyUmL1P+8HSTWPL35MdJB1FKTST
         Vqi+USYbAVTTb1Z2GS3VH9tm0yGdnS9Imnf7Tq9DeMMoRW3xpDcXylaN1EPqep0/L1yY
         VWbqI2YnfiZLo4+qZqVpaq9NAs44wTpR3OtBK/O35YH45hCS6v8Dqd04OIQpLrBQIfS9
         I2TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oLKBk3Q7ccO0NJJMRJYYFBU09UJHS0/ornRP0j3Fxnk=;
        b=PUAK0zYdPQvBxRnfjR8pzbDM6vF+MD2GA29rENh+ssCK5PC0tu9/OYoYHIpYqq85Lm
         jO2oWy+z2zm+4dSIWXPD9DgQonE8ndLa6zZR7Qb0PrQTiPzUR2tAyJXtZ9guhtkoDVXw
         435k7r/gEJV+aa6DrV+bnaqXtTIVBEILS3jaLfjbnqdAxWgacR3+B71TifU1frmjnuiI
         qxNvKnp8zEX27MahwrnCTqtJOx5o+f0SQ6fNQqEBnQPIgDLtZT2LhXu1xR3BnNAmmbCd
         qxAbuWGUDDoeDHY9SKyTiI661jKP+Abk4evsFEdoEc3Y/yCPTxqlztoJXPRSLgNzFVmv
         vnAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=gmeYon7z;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h187sor377221oib.95.2019.06.12.11.50.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 11:50:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=gmeYon7z;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oLKBk3Q7ccO0NJJMRJYYFBU09UJHS0/ornRP0j3Fxnk=;
        b=gmeYon7zauy3OQh0dds8NZYm6t5UDisLz6yhyFv+zAHzAQld3I1PlASf7zsZM+CaaZ
         CehQMBgQdj6gortTquDOB3N7bsSZoRiiIPq0F65TSYhGSEiVglTlgXcZdamdruNK0EZE
         L4hW+NB6I/OXN8FIUSFL51bNjJWJFW8hzlwgXFjesNuMtfLc6oA7+M/3K2vidJa0br9V
         czG4Eoe/orE9D++K3+lLCE4n/UgTBq+X11qW/QB7IGhWEAbaQV6NagrYsJ8UOQey3FsU
         R4uBxwDIf6zhdzoruyQQmgKdtCNWOHRzy7IMkgSp8cIYB925DCaZB8zX5lMCi8WnCkui
         Earw==
X-Google-Smtp-Source: APXvYqxnUAltCxrDlkjMuVh0Fis6UXRXzk4ak5OCGI7cs5NoWVrVaXVk3zYCAPwY8b7pSu88qbXHjB+1CYR77yxpUws=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr420099oih.73.1560365403007;
 Wed, 12 Jun 2019 11:50:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190606014544.8339-1-ira.weiny@intel.com> <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca> <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz> <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com> <20190612102917.GB14578@quack2.suse.cz>
In-Reply-To: <20190612102917.GB14578@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Jun 2019 11:49:52 -0700
Message-ID: <CAPcyv4jSyTjC98UsWb3-FnZekV0oyboiSe9n1NYDC2TSKAqiqw@mail.gmail.com>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
To: Jan Kara <jack@suse.cz>
Cc: Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>, "Theodore Ts'o" <tytso@mit.edu>, 
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

On Wed, Jun 12, 2019 at 3:29 AM Jan Kara <jack@suse.cz> wrote:
>
> On Fri 07-06-19 07:52:13, Ira Weiny wrote:
> > On Fri, Jun 07, 2019 at 09:17:29AM -0300, Jason Gunthorpe wrote:
> > > On Fri, Jun 07, 2019 at 12:36:36PM +0200, Jan Kara wrote:
> > >
> > > > Because the pins would be invisible to sysadmin from that point on.
> > >
> > > It is not invisible, it just shows up in a rdma specific kernel
> > > interface. You have to use rdma netlink to see the kernel object
> > > holding this pin.
> > >
> > > If this visibility is the main sticking point I suggest just enhancing
> > > the existing MR reporting to include the file info for current GUP
> > > pins and teaching lsof to collect information from there as well so it
> > > is easy to use.
> > >
> > > If the ownership of the lease transfers to the MR, and we report that
> > > ownership to userspace in a way lsof can find, then I think all the
> > > concerns that have been raised are met, right?
> >
> > I was contemplating some new lsof feature yesterday.  But what I don't
> > think we want is sysadmins to have multiple tools for multiple
> > subsystems.  Or even have to teach lsof something new for every potential
> > new subsystem user of GUP pins.
>
> Agreed.
>
> > I was thinking more along the lines of reporting files which have GUP
> > pins on them directly somewhere (dare I say procfs?) and teaching lsof to
> > report that information.  That would cover any subsystem which does a
> > longterm pin.
>
> So lsof already parses /proc/<pid>/maps to learn about files held open by
> memory mappings. It could parse some other file as well I guess. The good
> thing about that would be that then "longterm pin" structure would just hold
> struct file reference. That would avoid any needs of special behavior on
> file close (the file reference in the "longterm pin" structure would make
> sure struct file and thus the lease stays around, we'd just need to make
> explicit lease unlock block until the "longterm pin" structure is freed).
> The bad thing is that it requires us to come up with a sane new proc
> interface for reporting "longterm pins" and associated struct file. Also we
> need to define what this interface shows if the pinned pages are in DRAM
> (either page cache or anon) and not on NVDIMM.

The anon vs shared detection case is important because a longterm pin
might be blocking a memory-hot-unplug operation if it is pinning
ZONE_MOVABLE memory, but I don't think we want DRAM vs NVDIMM to be an
explicit concern of the interface. For the anon / cached case I expect
it might be useful to put that communication under the memory-blocks
sysfs interface. I.e. a list of pids that are pinning that
memory-block from being hot-unplugged.

