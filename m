Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A59DCC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:09:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E74B20866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:09:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E74B20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF0BF6B0007; Wed, 12 Jun 2019 08:09:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9F126B027A; Wed, 12 Jun 2019 08:09:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B67CD6B027B; Wed, 12 Jun 2019 08:09:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4A46B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:09:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d13so25625038edo.5
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:09:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IvZbRoqVy0I4pzvEu6n62Bm2PCJYWpH1flcTQkqaVao=;
        b=kpvgkJAkOpS2gbR1XaIZb8UecKJdQBHST6ybusSQIzQ9krkTKDiHjRuoyLl3RqSAkN
         iQAV+4Qt6mMjbizps330DoM4dSmz4kpj01Ae5iTTvT5fRwnZsFe/cLnzDxmZSSfYPAqw
         P2EMACyUdVDcYJ0U3uWBRWmSJokve4wvVtwHj1RMwCfX0lKaQCJuXMkHp0yTAQBNPcxJ
         SCn1rA0Zks4+tHK+N12nSj2oyyAZKX7ugphu1yys2KA4ABXGo7i3w24wLldm8TLFMJoE
         MuuvdafqmX7XKHdfGYxsHJXOKCgVQc9CtGK+aiE9VDHK0T8rVgWg/voiIFqzHb/8XXWb
         VUZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVoCB6XPmqSOiSIwNjJM4humyOLDUn03PO74KK+Khh+aHq/dSIm
	qTam0YiW28B5llqbWGJXOkZSNTn7m+sVdo98+6WbtQjCs7+Rd42yAakOtZAt1y5iHdYoK/a4FOe
	5hK9x8DzSl3RLeFWka1YdxK8c+X+qWqovU//G/ssEMhBBViUUoTJ+j4zxvb4GIZGGlg==
X-Received: by 2002:a50:9590:: with SMTP id w16mr65284266eda.0.1560341352001;
        Wed, 12 Jun 2019 05:09:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkUJxFpY13TiU6hTwqxFBsJMvYcfIsXIrG3DCMkrUBUa8Qxi9dFj3GD0uYfp7pjxUqIKSX
X-Received: by 2002:a50:9590:: with SMTP id w16mr65284146eda.0.1560341351031;
        Wed, 12 Jun 2019 05:09:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560341351; cv=none;
        d=google.com; s=arc-20160816;
        b=T15c4afBR2ZnGq8iFlh0OHOJe08JJWiSvMZQr0LUqNsWOWM2HJifB1mP9p8RGBQL9Y
         9xigVCrdf3oqalkZzSmc36v7Vv2ZEi1ubIKNwQJyhxPvxKmRCmARIGqd66nipuXPCYbN
         mHywdWa9UMsLdoIUxk+tftw1FUGOMcImycKlpwyIV6iLynjRfb/MrITNbroRiSo1i3A0
         223o8yg5+i2yhnNgsR0BLPrrtHzrKFaB2eYUTDxJKeEk2+2WPJXs1igXJ9r41cgQKRxp
         5sBDAbNh5D3Xtf18CnEjcsjio5WKkVIbRQaRQHxOt0h/k2cVopGv5ZDsL0kavWnpPFrR
         T52g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IvZbRoqVy0I4pzvEu6n62Bm2PCJYWpH1flcTQkqaVao=;
        b=GL/+Ig6Tg1sUb8Xx2KTv/FFtZquS5KWUNmkGDFbQYv/MnoP+hR//Ze5QLrwOBrDpOL
         I739KdOzR/cVOwaSUm2uV7WAXC65MxY3FnEVHAkrQGAps6S7olryQ/LKznVlZUXXGDVF
         ga7AVfw6qJGv4Bp37ML4a7cgrKZWdGpqXVlTuVyaj7RAx5badleZ4enpauT4Zw0LGQ6E
         EEHDMJkCinG0kUTb+m9AkrY+yg5hJ5+3Gsk0NOnXrsDpqboJf+R71qMmVGzmUozoyGKQ
         hXsVS88O/p1P66n84EvXsbAs3ElYFg3lRPQDZjoGE9CZG5e6cM/LSrkaB3GJWrrNA3g0
         mh5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h44si4725282eda.49.2019.06.12.05.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 05:09:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 83424AE27;
	Wed, 12 Jun 2019 12:09:09 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id A86331E4328; Wed, 12 Jun 2019 14:09:07 +0200 (CEST)
Date: Wed, 12 Jun 2019 14:09:07 +0200
From: Jan Kara <jack@suse.cz>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190612120907.GC14578@quack2.suse.cz>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612114721.GB3876@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 12-06-19 08:47:21, Jason Gunthorpe wrote:
> On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:
> 
> > > > The main objection to the current ODP & DAX solution is that very
> > > > little HW can actually implement it, having the alternative still
> > > > require HW support doesn't seem like progress.
> > > > 
> > > > I think we will eventually start seein some HW be able to do this
> > > > invalidation, but it won't be universal, and I'd rather leave it
> > > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > > on fire, I need to unplug it).
> > > 
> > > Agreed.  I think software wise there is not much some of the devices can do
> > > with such an "invalidate".
> > 
> > So out of curiosity: What does RDMA driver do when userspace just closes
> > the file pointing to RDMA object? It has to handle that somehow by aborting
> > everything that's going on... And I wanted similar behavior here.
> 
> It aborts *everything* connected to that file descriptor. Destroying
> everything avoids creating inconsistencies that destroying a subset
> would create.
> 
> What has been talked about for lease break is not destroying anything
> but very selectively saying that one memory region linked to the GUP
> is no longer functional.

OK, so what I had in mind was that if RDMA app doesn't play by the rules
and closes the file with existing pins (and thus layout lease) we would
force it to abort everything. Yes, it is disruptive but then the app didn't
obey the rule that it has to maintain file lease while holding pins. Thus
such situation should never happen unless the app is malicious / buggy.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

