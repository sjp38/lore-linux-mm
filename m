Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04FCCC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 21:20:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0DB7217D8
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 21:20:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0DB7217D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 525AF8E009F; Fri,  8 Feb 2019 16:20:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4ABAD8E009B; Fri,  8 Feb 2019 16:20:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34CF08E009F; Fri,  8 Feb 2019 16:20:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5C518E009B
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 16:20:32 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a26so3696457pff.15
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 13:20:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+QNVvVPcimlB/wqY8iBv8HCgkzdR8wdVx6Bil8cHLrI=;
        b=Sa1hDLSIy7PjrkTkxTitbMptLtRV+G/Is+5Z7VpNxfHh+DFkrzvPhokrvVK7xu5kSe
         R+kziBX4Fl6w4QyaaLz/npJOWNUHjW8HqGBl+e2vFrlH00H0p8N+jW8N8ASW0wwiQIzr
         NEMv2Ns7Qsqd54U3WgJCqPYP2pxTp7PgcdTCbqKsWQTpCdyzYfucVWtxuWqccCK+o3J5
         P6jfTzLb8jDkheiFmRntIs5s6KlbIZjVq1PxcTnHcG92aoW/h7a34y/NlhjXTHWf+K5s
         1TsGrSOl1ifAJBP0Jn6Ikyt/B9zthUQoGrgZX1UC2boecyPUFvxORc6+krBASPzS/LnH
         4pfA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAub2MTP0EMoGzlPtYILWzhfoDlCxpEY2SyWnENjV2ZigKPeQ/ewF
	EaD3FEuM+K5qRCTywL1ajpszCUOM2XUMnMzR2upTf9QUU3iYz9VBVYAhEVVA/NeQt5ienEi42Bs
	PPmYddCA4AdWCRpXleF8M9hX1ayReoZJNbGjjYIEyRQaQOHOC/BKXY36r+PAvC6Q=
X-Received: by 2002:a17:902:8e8b:: with SMTP id bg11mr25224051plb.332.1549660832471;
        Fri, 08 Feb 2019 13:20:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZWr8wMD7mdHcqMNwcIW78bv1f6atHdKkyi/0GlbjpPZei4z3kO++xwO+Oorb+vw9hewHVx
X-Received: by 2002:a17:902:8e8b:: with SMTP id bg11mr25223980plb.332.1549660831427;
        Fri, 08 Feb 2019 13:20:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549660831; cv=none;
        d=google.com; s=arc-20160816;
        b=OzMl9Jn00Y/gvv+DBpasDijCwKjBrXvfPJV20vhhXLLTBXRbMjTZYKEmZySMN8L0kq
         zBlcFXlCRYiYIRRq+mONULpTpTrKIJvRuERDpf+Ry+PzQXljfQK233YhHgflLmviUQ9W
         2IKGgUWBmLvwDiFHiael/5Dz5q3RIpus1lBzXBQL67Hbq+GOLGnVm8Dr4HwwMwC//m1N
         fxO2CQ14x4qknICe5FsRcsVP6Q8XWlOiq8GsYO7pMzLfMgBerWftyU3GHcaFHJXM+p9B
         TPBkfRfQ372WKlPKAs9UaROIdjGNz57gY3EnOi5U9CusuwAkxd0Qsdv/DVsvpmz8FZpR
         hzPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+QNVvVPcimlB/wqY8iBv8HCgkzdR8wdVx6Bil8cHLrI=;
        b=k1Xth/2d+yxye7HjMit/ivN5nREgk/47Hf8CDo57Gn5lKI86HdHnq/G4rEcnddwRmd
         TE1LpQlQ75dC3v7qTtBCM5X4FAfSNineEtRuLy0AYvyi14qoGxJvFPMN899yBD3BeM+w
         D4QZSoZKn9ibj6to3fyJ+1FzjLtbRwExpIYUKm6z/zuooYRPqOgpwnNLsoJkwJ/pwTNV
         C7pJsb1gUvkH9gWStWNUhqY/6qRrN1eoMScRwfyzstC1l2E9t3y43NOuod/Aofa8ruA9
         myZR4KoYg+0Nys6QUP5pa0iPhpe/nG8IAylMIqBENLSVwljFZlILenh7Mms0bbxLcu6+
         0j+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id w2si3320373pfn.48.2019.02.08.13.20.30
        for <linux-mm@kvack.org>;
        Fri, 08 Feb 2019 13:20:31 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 09 Feb 2019 07:50:28 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gsDZS-0006P0-Be; Sat, 09 Feb 2019 08:20:26 +1100
Date: Sat, 9 Feb 2019 08:20:26 +1100
From: Dave Chinner <david@fromorbit.com>
To: Jan Kara <jack@suse.cz>
Cc: Christopher Lameter <cl@linux.com>, Doug Ledford <dledford@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190208212026.GB20493@dastard>
References: <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208111028.GD6353@quack2.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 12:10:28PM +0100, Jan Kara wrote:
> On Fri 08-02-19 15:43:02, Dave Chinner wrote:
> > On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> > > One approach that may be a clean way to solve this:
> > > 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
> > >    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
> > >    on the longterm pinned range until the long term pin is removed.
> > 
> > So, ummm, how do we do block allocation then, which is done on
> > demand during writes?
> > 
> > IOWs, this requires the application to set up the file in the
> > correct state for the filesystem to lock it down so somebody else
> > can write to it.  That means the file can't be sparse, it can't be
> > preallocated (i.e. can't contain unwritten extents), it must have zeroes
> > written to it's full size before being shared because otherwise it
> > exposes stale data to the remote client (secure sites are going to
> > love that!), they can't be extended, etc.
> > 
> > IOWs, once the file is prepped and leased out for RDMA, it becomes
> > an immutable for the purposes of local access.
> > 
> > Which, essentially we can already do. Prep the file, map it
> > read/write, mark it immutable, then pin it via the longterm gup
> > interface which can do the necessary checks.
> 
> Hum, and what will you do if the immutable file that is target for RDMA
> will be a source of reflink?

I think we'd have to disallow it. reflink does actually change the
source inode on XFS (adds an inode flag to say it has shared
extents)...

Similarly, we'd have to make sure the inode is pinned in memory
but the gup_longterm operation, not jus thave it's pages pinned...

> That seems to be currently allowed for
> immutable files but RDMA store would be effectively corrupting the data of
> the target inode. But we could treat it similarly as swapfiles - those also
> have to deal with writes to blocks beyond filesystem control. In fact the
> similarity seems to be quite large there. What do you think?

Yes, swapfiles are probably a better analogy as the mm subsystem
pins them, maps them checking the layout is appropriate (i.e. no
holes) and then writes straight through them without the filesystem
being aware of the IO....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

