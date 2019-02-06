Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06F4FC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 21:32:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE57F218E0
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 21:32:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE57F218E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D4A48E0101; Wed,  6 Feb 2019 16:32:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4838F8E00EE; Wed,  6 Feb 2019 16:32:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 373FC8E0101; Wed,  6 Feb 2019 16:32:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E735C8E00EE
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 16:32:16 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id f69so6244846pff.5
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 13:32:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NcyN0yHV1Ys9MIRPSBDNu4WzDmgXwJtP8q9wZrDgVXM=;
        b=tw+xKmd0fIn3gDLXJCSLXTqcuO3pdUbZkKjGgH8PhLm6lDqjOncuK/J1EItQ7BYEcB
         n25YPlZMoBLO/0/NSduY0Yav+rYsNAO9Mv8c++FqEuy8LVM2RBotb/IV2eIuUcWNzeRD
         JoK25IPlYDu19V9uRjfw6ODaRes3UBXSGs3jbBvzKN5upzOjU5IsXoCRSzpj/6Smoorv
         lelvNV9nB65xILxfnpWjPU4MGVxQm+0V236F51xcMhMYtEznNpNvqcyrC2RsZ+mPtNol
         tqWnd2yZMWko2D94qr/m04RSxmhwaGQxnYBSEg1D5eZB6YN7H6L6qXmcX28iznglVJ/o
         BXQg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.129 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAubhTlFdthXAVbAgrUSoytcP/MfI8VWp23V0O6NZbWS3nFC7IlQF
	OMn2DHFmHD37+hxdwx3DFRWOx65qw+glUapZ0Ksj/aPbBNzMC9h8VOkZagW+NTzADkgABbIKSPI
	lqDUDp2MIj7tWgGWZo9yIdiCJhKughXLSEItf+pj4Joly4wv2TKSSMNoApOzkPg8=
X-Received: by 2002:a62:3141:: with SMTP id x62mr12550344pfx.12.1549488736589;
        Wed, 06 Feb 2019 13:32:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbyWLNkwDFdi3gdHF2/K/a6uGWu8vSvb2LRBpOHhEtJxbwBgI2coWRdF9qkOzzNXloQbj6Y
X-Received: by 2002:a62:3141:: with SMTP id x62mr12550290pfx.12.1549488735739;
        Wed, 06 Feb 2019 13:32:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549488735; cv=none;
        d=google.com; s=arc-20160816;
        b=yHjR8fmFN0kp2790j5pxA6f7i/AGyfUiNt1FUIF+4SaJmv04vBut6axPLeNA4QDomN
         IYcIHauYQKkFQZpuVPVue4GfScVewoDL0DT3fOoICcNiXsbGDu+D94IFSTR4e/okPwGi
         HWfVT2S3aBolthA70eEcLz78iEGSJ1+UfAFLmMvGsaXuyzNdVKfo0GQt5Or9+8f8PKLs
         VrRnqAosrvVENQ/3ckdaP4uEwIav9PTVsyZmoqlZJAUY6+g0X1UKLx8lgKcJ7p3w0NtO
         aNTjgB8/ShdWcHlu2wmcKp573OJIA7QWn7SgNijYJO+L/pqzjju3dBDmI6fQdZbdRFFf
         u+AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NcyN0yHV1Ys9MIRPSBDNu4WzDmgXwJtP8q9wZrDgVXM=;
        b=WLORtfAkNL6sRi28pmSICX9s7q0veiqQ3SnGVLzawnt8d/DbIQKCC6Skek8vgiuwkX
         liNvVDNK/xUj8x/RMmkdkpSQVUOllOQyQc1XMnxe2RZTEKDkcaEhWApKlGW2U6YxGPA3
         a3M7cGwZDoYiThv1c4IjPDLX8cOC6lpNdj2QaPzQS+ldChfQHRGHAqJbmACyaaXz+KgC
         ZQu57TbBWOAKW7RpZscGDbV5NKNGUqnZ18hP1YTxSg0325I8XWDEKaoazBI/VcU7mIjP
         BiZ4XXhEGh8rvBzjZaxXdzo/tuoKDexkaFWjSOIXhtL0TgKkO02jm2FKG6I7yv+npUxi
         Gv/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.129 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id t11si6027936pgv.251.2019.02.06.13.32.14
        for <linux-mm@kvack.org>;
        Wed, 06 Feb 2019 13:32:15 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.129 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.129;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.129 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl2.internode.on.net with ESMTP; 07 Feb 2019 08:01:49 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1grUnL-0003Lg-7s; Thu, 07 Feb 2019 08:31:47 +1100
Date: Thu, 7 Feb 2019 08:31:47 +1100
From: Dave Chinner <david@fromorbit.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Doug Ledford <dledford@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206213147.GA6173@dastard>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190205180120.GC21617@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190205180120.GC21617@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 10:01:20AM -0800, Ira Weiny wrote:
> I had an old invalid address for Jason Gunthorpe in my address book...  
> 
> Correcting his email in the thread.

Probably should have cc'd linux-fsdevel, too, but it's too late for
that now....

> On Tue, Feb 05, 2019 at 09:50:59AM -0800, 'Ira Weiny' wrote:
> > 
> > The problem: Once we have pages marked as GUP-pinned how should various
> > subsystems work with those markings.
> > 
> > The current work for John Hubbards proposed solutions (part 1 and 2) is
> > progressing.[1]  But the final part (3) of his solution is also going to take
> > some work.
> > 
> > In Johns presentation he lists 3 alternatives for gup-pinned pages:
> > 
> > 1) Hold off try_to_unmap
> > 2) Allow writeback while pinned (via bounce buffers)
> > 	[Note this will not work for DAX]
> > 3) Use a "revocable reservation" (or lease) on those pages
> > 4) Pin the blocks as busy in the FS allocator
> > 
> > The problem with lease's on pages used by RDMA is that the references to
> > these pages is not local to the machine.  Once the user has been given access
> > to the page they, through the use of a remote tokens, give a reference to that
> > page to remote nodes.  This is the core essence of RDMA, and like it or not,
> > something which is increasingly used by major Linux users.
> > 
> > Therefore we need to discuss the extent by which leases are appropriate and
> > what happens should a lease be revoked which a user does not respond to.
> > 
> > As John Hubbard put it:
> > 
> > "Other filesystem features that need to replace the page with a new one can
> > be inhibited for pages that are GUP-pinned. This will, however, alter and
> > limit some of those filesystem features. The only fix for that would be to
> > require GUP users monitor and respond to CPU page table updates. Subsystems
> > such as ODP and HMM do this, for example. This aspect of the problem is
> > still under discussion."
> > 
> > 	-- John Hubbard[2]
> > 
> > The following people have been involved in previous conversations and would be key to
> > the face to face discussion.
> > 
> > John Hubbard
> > Jan Kara
> > Dave Chinner

Just FYI, I won't be at LSFMM.

Puerto Rico is about as physically far away from me as you can get
on this planet. There's 40 hours in transit from airport to airport,
and that doesn't include the 5 hours of travel the day before (and
hence overnight stay) to be able to get to the first airport in time
for the first flight. I'm looking at a transit time - if all goes
well - of over 60 hours just to get to the conference.

And it's looks like it will be just as bad on the way back.

6 days travel for a 2 day conference makes no sense at all.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

