Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1358C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:17:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8490620866
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:17:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8490620866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E765A6B0006; Thu, 13 Jun 2019 03:17:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4D3B6B0007; Thu, 13 Jun 2019 03:17:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3BAD6B000A; Thu, 13 Jun 2019 03:17:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7275C6B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:17:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so29628451eda.3
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:17:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5ve0fQ6y2AApSuSxdKF91u1GshVI+/HZskoxA8QEWc4=;
        b=FtMuUHvd/90yJr001tGaegZTxKMfoHQLW2af7WM+oQVIyrpXg9G4YWHV5sIiNnOoF5
         yrAaV3BSx87GGfFu5uqfZA6DmwAvMYzrVa+rCx9zWaQ08MI0OtHldJY6lWEb7g4b7DAT
         c8XBx0hf8leuDJU2+cl31WYU/fYj4kTS0pgCGoxA6LArp8WgTgng/GQJVtHnA2FxTl8P
         /is4QHKORiU8AHuTRwT3sfi3bfCV9STGMVCShnGVgHugpj6dFITHVFIfwelVIDX7tq4M
         2rCWwaRJK9cNPa7YdKmvzW54h5Edta+HnHmvmhDCVxM2/CqQdR59O3F5Dk5RPy3nx+CD
         /lQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWfuHmLItTZDIVT+WW1vfpo4RWKozP7cvkWjSE6VhHKYIaNay3i
	YmAy8zzIC88ap7YVFr1clSySpMxEaLYZUDfTdVJMxqUPIe64QA/sFJz/6TL19m+/iYtO5TjlAjv
	BpACgTTizJ20cv5W1Ie54gVvqI+AWOFp1UGOCvIi/HLXbgHw0YL76bK1vdZF63g5c1A==
X-Received: by 2002:a50:d791:: with SMTP id w17mr90922967edi.223.1560410273022;
        Thu, 13 Jun 2019 00:17:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSa2v4DiR3J1tXCjAFD8b2mHCKXEkJjsORY+/gxEmNXFpmToyAnwe9B6EuoKr7rL0F2z+Q
X-Received: by 2002:a50:d791:: with SMTP id w17mr90922903edi.223.1560410271996;
        Thu, 13 Jun 2019 00:17:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560410271; cv=none;
        d=google.com; s=arc-20160816;
        b=Lcf+zwnxKamWU+6a4z9c0RjDIr6FeQUlfY1kOP6rCSBC/rtstn6q9B0pYCWA9wVP1Y
         1EATl8JFvVYRF+bR5/bX6udhBTnWGzKdZKAodaOFn56vBk5/hgFhM+FuMNrmgu1M2fwZ
         jHjpXR7PGB8SQnttKoTWe3QpCc6fC0wDdQfnjuC+nKWmjQmg+ym0o75uJa4NduJa7jIy
         wdIy1euRGlUPFWbWbWmtl84C2ctIG5YafUBeDucZ3+CzYu22dV2Uy8WxZxkkq6HQd+jW
         PQpgox76byeAnuavKL30KPqfeWz0jpIW8U+pgJrKju55tDKvVe9BEXS6PEzZvDuGQowW
         tyfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5ve0fQ6y2AApSuSxdKF91u1GshVI+/HZskoxA8QEWc4=;
        b=gIHzerwjG5pMpSa9Y+xZKRGqkAE+SiRp3jf9yghsdrVkQJRgHqOr9SbFphHc5OGDEq
         +3buAhyVdjuG/uiTVYJtL9z4G7d2uP5bPddl3uitAGYh8X0fibiWcCGutbRQAtoRNrjz
         mrTnaPj2RfNwOuo/eCUBVQMyM0LeZG61SSwJJ4KPahAHLE3WK5Zi3JmvX3k3gU/Smph2
         krV2RVA9lv6ZaZF4qGxu1ha/LAtfAJbe6iRsC7Yld+E2gSiWgS7mwHt+dilA45eUPS0E
         1VBEAVwtimcYwK8/icuGjBnUTYLKbaWcyQ7l4Rtkrd7zTEXlyZR17CZoXgTtQE+jkuYX
         KcEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n12si1420549ejk.343.2019.06.13.00.17.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 00:17:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 45815AF05;
	Thu, 13 Jun 2019 07:17:50 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 051E71E4328; Thu, 13 Jun 2019 09:17:47 +0200 (CEST)
Date: Thu, 13 Jun 2019 09:17:47 +0200
From: Jan Kara <jack@suse.cz>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Ira Weiny <ira.weiny@intel.com>, Theodore Ts'o <tytso@mit.edu>,
	Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs <linux-xfs@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	linux-ext4 <linux-ext4@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190613071746.GA26505@quack2.suse.cz>
References: <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca>
 <20190612120907.GC14578@quack2.suse.cz>
 <CAPcyv4ikn219XUgHwsPdYp06vBNAJB9Rk-hjZA-fYT4GB3gi+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4ikn219XUgHwsPdYp06vBNAJB9Rk-hjZA-fYT4GB3gi+w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 12-06-19 11:41:53, Dan Williams wrote:
> On Wed, Jun 12, 2019 at 5:09 AM Jan Kara <jack@suse.cz> wrote:
> >
> > On Wed 12-06-19 08:47:21, Jason Gunthorpe wrote:
> > > On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:
> > >
> > > > > > The main objection to the current ODP & DAX solution is that very
> > > > > > little HW can actually implement it, having the alternative still
> > > > > > require HW support doesn't seem like progress.
> > > > > >
> > > > > > I think we will eventually start seein some HW be able to do this
> > > > > > invalidation, but it won't be universal, and I'd rather leave it
> > > > > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > > > > on fire, I need to unplug it).
> > > > >
> > > > > Agreed.  I think software wise there is not much some of the devices can do
> > > > > with such an "invalidate".
> > > >
> > > > So out of curiosity: What does RDMA driver do when userspace just closes
> > > > the file pointing to RDMA object? It has to handle that somehow by aborting
> > > > everything that's going on... And I wanted similar behavior here.
> > >
> > > It aborts *everything* connected to that file descriptor. Destroying
> > > everything avoids creating inconsistencies that destroying a subset
> > > would create.
> > >
> > > What has been talked about for lease break is not destroying anything
> > > but very selectively saying that one memory region linked to the GUP
> > > is no longer functional.
> >
> > OK, so what I had in mind was that if RDMA app doesn't play by the rules
> > and closes the file with existing pins (and thus layout lease) we would
> > force it to abort everything. Yes, it is disruptive but then the app didn't
> > obey the rule that it has to maintain file lease while holding pins. Thus
> > such situation should never happen unless the app is malicious / buggy.
> 
> When you say 'close' do you mean the final release of the fd? The vma
> keeps a reference to a 'struct file' live even after the fd is closed.

When I say 'close', I mean a call to ->release file operation which happens
when the last reference to struct file is dropped. I.e., when all file
descriptors and vmas (and possibly other places holding struct file
reference) are gone.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

