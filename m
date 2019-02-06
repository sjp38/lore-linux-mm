Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26AD0C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 21:04:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFC22218D3
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 21:04:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFC22218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 782FC8E00FE; Wed,  6 Feb 2019 16:04:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 732F28E00E6; Wed,  6 Feb 2019 16:04:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D19F8E00FE; Wed,  6 Feb 2019 16:04:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1662A8E00E6
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 16:04:04 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f69so6183321pff.5
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 13:04:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2BBclUhpbbdOFmTdS4/X49c+S0gpKP2Zv/No9gKegoo=;
        b=qSgvLeqQq109lQHHsF50sl6V0XZHCsP/Z/PDxzWS9JquRCkqhd54aHxfJyNRTcxbUD
         JKo6R0VbPshIEJ0Y/Z1fsDIpyyb4BBarwWXPV8LTPjh/qcVO18pbw7JTOjdnPQy1zPVd
         RdrOFRPFGimYYpWBteKKBX1+3pzZ+J3sTyUWQ5aWFOC+8XWCl6HK/GBXfmJ0nqjxle4G
         YjgRIvHDgiMuA3GABjTI3x2sxjs2Qr3VoAH0JRvPYWCAct+/a7pA6Sh/UTCxGYW+Br0i
         R5LIaklGSp/jdy6wprqz6VNOfi3L7G+vUjGXYgeduP0Z49S3a0QddBEanRYHSAsHcpHn
         UffA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuaQV+HZe/6WDqp49Ke1k19uQEF2qH8MbxyzdpH6DO+Lt9sf04m0
	jAo0Jbo33dskrMY8j+6d2U3Q4ydZ336CPqes02PxsUpul/xGy4OGj8nt1LnOJHkwxXlzBZtQeuS
	cgddAmI/zHswgRLXDGMreHEIAmCGm1MWtbUmWteNGRSBG+qv+Sk7ETD+z6Xmwsc4=
X-Received: by 2002:a63:5463:: with SMTP id e35mr6693256pgm.260.1549487042749;
        Wed, 06 Feb 2019 13:04:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYcEM9SUjt9O9NiQtJr00Lhj9EYbuO91UsXMxC4pMW6QOAvIv8XK9WENJaPc/Oepf8I7khN
X-Received: by 2002:a63:5463:: with SMTP id e35mr6693088pgm.260.1549487040268;
        Wed, 06 Feb 2019 13:04:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549487040; cv=none;
        d=google.com; s=arc-20160816;
        b=tgBtxWHeDFH0KJP0F82z5eO/TXMhWYTAOSNRdU/jbYXziyNOUSt3NLoQR1tnMeOJuL
         VdGNZ1oDspqxhoKpMUAmQXiOyAbQoF4WGMaJKyhwJcSSaUhxMfR7jw40oxsYBB7XmITZ
         VYVB2ftBKGoJ8qvMp52ode5g/pP03XrB+jl1/4Wnc2+PUHwg2qIKr3qsWcTpqQC1/b3j
         yjFXp5ACOFFNxQCmHghHEYrPh7L9+FmT6ggJaH0U0s/bhw9na1NK8wS5itz7AJS4yM+p
         MKT/pP9o9y2CvL7BTcyrSBmqD2Cc+V5LTeIOg8F1fyJvETb0Kvb+1vAyfJwTudStXMwA
         QPqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2BBclUhpbbdOFmTdS4/X49c+S0gpKP2Zv/No9gKegoo=;
        b=KQmhvOMLSP3gp1OKOEgSS58LVhvI5QvIzdewIrFULsh4s7LBYfqB4IEXmRitmxtLk3
         zDb0y9/yI86KFY+m4DdG0wkoXp2QuDDcbMU7cp1J1OEgO0+FgrIji1tBR5tB7z6fv4tK
         CgB6dfQlXx8pcLwLlKi07pZXam/ssP7/vkpZFYyyq9tkMib/i1KT6vMtz3WszLqEAk4+
         UC1BN+cHTqB6NRJadQ5814Mkh5ex+l8/heZOhaqW7Vk6Fyuur7TOjKBp8a02ITLMsRTH
         P++NYAl2rHXRrqmPtrS7nAiOCuWQsoMfC6iyHhquqBOy0i+gHIVBvicK/pGE0OgjFCfM
         0Zog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id z7si6768846plo.266.2019.02.06.13.03.59
        for <linux-mm@kvack.org>;
        Wed, 06 Feb 2019 13:04:00 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 07 Feb 2019 07:33:59 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1grUMO-0003Ji-FA; Thu, 07 Feb 2019 08:03:56 +1100
Date: Thu, 7 Feb 2019 08:03:56 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christopher Lameter <cl@linux.com>
Cc: Doug Ledford <dledford@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206210356.GZ6173@dastard>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> On Wed, 6 Feb 2019, Doug Ledford wrote:
> 
> > > Most of the cases we want revoke for are things like truncate().
> > > Shouldn't happen with a sane system, but we're trying to avoid users
> > > doing awful things like being able to DMA to pages that are now part of
> > > a different file.
> >
> > Why is the solution revoke then?  Is there something besides truncate
> > that we have to worry about?  I ask because EBUSY is not currently
> > listed as a return value of truncate, so extending the API to include
> > EBUSY to mean "this file has pinned pages that can not be freed" is not
> > (or should not be) totally out of the question.
> >
> > Admittedly, I'm coming in late to this conversation, but did I miss the
> > portion where that alternative was ruled out?
> 
> Coming in late here too but isnt the only DAX case that we are concerned
> about where there was an mmap with the O_DAX option to do direct write
> though? If we only allow this use case then we may not have to worry about
> long term GUP because DAX mapped files will stay in the physical location
> regardless.

No, that is not guaranteed. Soon as we have reflink support on XFS,
writes will physically move the data to a new physical location.
This is non-negotiatiable, and cannot be blocked forever by a gup
pin.

IOWs, DAX on RDMA requires a) page fault capable hardware so that
the filesystem can move data physically on write access, and b)
revokable file leases so that the filesystem can kick userspace out
of the way when it needs to.

Truncate is a red herring. It's definitely a case for revokable
leases, but it's the rare case rather than the one we actually care
about. We really care about making copy-on-write capable filesystems like
XFS work with DAX (we've got people asking for it to be supported
yesterday!), and that means DAX+RDMA needs to work with storage that
can change physical location at any time.

> Maybe we can solve the long term GUP problem through the requirement that
> user space acquires some sort of means to pin the pages? In the DAX case
> this is given by the filesystem and the hardware will basically take care
> of writeback.

That's what the revokable file leases provide (it's basically the
same thing as a NFSv4 delegation). We already have all the
infrastructure in the filesystems for triggering revokes when
needed (implemented for pNFS a few years ago), and DAX already
piggy-backs on that infrastructureuses that infrastructure to wait
on gup pinned pages. See dax_layout_busy_page() and BREAK_UNMAP.

The problem is that dax_layout_busy_page can block forever when
userspace pins the file for RDMA. It's not just truncate - it's any
filesystem operation that needs to manipulate the underlying file
layout without doing data IO. i.e. any fallocate() operation, and
when we add reflink support it will include anythign that
shares or de-shares extents between files, too.

The revokable file leases are necessary because access to file data,
internal metadata and the storage is arbitrated by the filesystem,
not the mm/ subsystem and physical pages. i.e. FS-DAX means that the
*filesystem* is managing access to physical pages, not the mm/
subsystem. And we can't just ignore the filesystem in this case
because allowing access to the physical storage outside of the
filesystem's visibility and/or direct control is a potential
security vulnerability, data corruption or filesystem corruption
vector.

And that's the real problem we need to solve here. RDMA has no trust
model other than "I'm userspace, I pinned you, trust me!". That's
not good enough for FS-DAX+RDMA....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

