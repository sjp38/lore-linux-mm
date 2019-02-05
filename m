Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E7EAC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 17:51:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC01120811
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 17:51:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC01120811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 723238E0095; Tue,  5 Feb 2019 12:51:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CF1D8E0093; Tue,  5 Feb 2019 12:51:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 573608E0095; Tue,  5 Feb 2019 12:51:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07BDD8E0093
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 12:51:22 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 75so3105609pfq.8
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 09:51:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=w3tTpfbi8q1KiXBOzdn4gaqFUFlG6GIpYI17AwclZqE=;
        b=d3W6J5SYoO/MJgJa5JlW+BYR9CIqng+0PK1n5k7agDxnSA5X2vrc5QSTnU8ILSTJ3W
         6xMuC6IU8V8B4N91c7AdKfjk1Jvlzcq79Miau2S8w0NoMiaBdCwn8/yp+xJuiC9N3+4Y
         aiH226WXTCBdGUCJgKRp2yMTxhMzO8nwUBwOqP96BW8ymzB95UFN5v8eHtrEL2szMSui
         ijRxrVKDfS8ivC8moS14mU9sgE2xxGLTWjT5luRbtxhGMeww17umzSmgQ65KwqD8tlVH
         bS0BzJd6cWdeiUTfuMAO4Q2lzpNMd2Dp4c/PzSy14vWOaARhK/YKqE/b1QNeuZA8cZRz
         LVUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubqPFk+ro6dHdR3YdksDFseyZxQRbD2IU5OepocdfgDTkcZ++cn
	iGHTnG0PNEkjbqW3rkkO6mZeH4Hq3EQ8VdgwlstyRQ1KLCBITRiNAqOIjLoLV54Yh4ay40eHw8u
	q+b37bZT3t2/43aclNSEIZhGHQwjaBDfpNY+TyUzuyjngqcBFHTHSB5C9Cziw4zmY1w==
X-Received: by 2002:a63:f412:: with SMTP id g18mr5650645pgi.262.1549389081644;
        Tue, 05 Feb 2019 09:51:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaNImMTg3kG1ougyyV9NJY7clUMhHOfQspIMQol+U+ZCVvdCEc6WlCCKe/pvhYjH0V0ZQqF
X-Received: by 2002:a63:f412:: with SMTP id g18mr5650608pgi.262.1549389080883;
        Tue, 05 Feb 2019 09:51:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549389080; cv=none;
        d=google.com; s=arc-20160816;
        b=TLeFBWDfarZ0tbi18BeceiDl+J2vV4yiVOj5mwPhVQNGeT+lTuRR2MOluJMjZjhCm7
         Qi7Wn9uVNhTIEspPTJBJ5uM8qOO1guVwJ/xQg9Cw6yU4IMIh/om80ao6t8LOBRKrTtgR
         GUv1d/Br6y04j7l1o7S6BUXZTyIxRmxHS+aN/NZS6ZXKp7mWNY0GzlgGvhahx/NV7hR2
         0kwE6ZbFwtbqVasXlYmHMJMCTocUF7KzbOzHw4toi3patqrl/Qb1W5XhYdoJGpgQlnf8
         rKhKRGe80fSQoBg5DiE5O84Dy7Z62FtoezgBM3gWQ9gD6ZBuvktQXfa3YE/TurMeOvFr
         1GpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=w3tTpfbi8q1KiXBOzdn4gaqFUFlG6GIpYI17AwclZqE=;
        b=Yt0el/dH1gLrcChOx82NnuUXsHTkvDhQCU9ICJcK+OF2h1XdnU+HsqKmpNyePKZtqs
         0sILZmFwfqolTJrShU7paBCaZ8xfc0UgWRksgSWP+hG3NU0u86jz/LAEhzNmkLoMNnQ/
         c27R21q2sX8ozZsDkOsjL4NJJHzLJ1OVzruaYvhQTux2s3nT1r8ha/MDudyEQxubvCru
         ofYvMd/qhKJJidPlelOZWN+nuXPrAWUyvsaY8HHo1ggPb5ignu8rfiXIx8PMZWslh7y9
         ACkHO814aPuoxxpnXv3ij5f8kx49zr076dKuJqIEddE6bfxKK64ysDcl/6CaZLVgs0T0
         xb1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t17si1559782pfh.267.2019.02.05.09.51.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 09:51:20 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Feb 2019 09:51:19 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,336,1544515200"; 
   d="scan'208";a="297461517"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga005.jf.intel.com with ESMTP; 05 Feb 2019 09:51:18 -0800
Date: Tue, 5 Feb 2019 09:50:59 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Dave Chinner <david@fromorbit.com>,
	Doug Ledford <dledford@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
Message-ID: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


The problem: Once we have pages marked as GUP-pinned how should various
subsystems work with those markings.

The current work for John Hubbards proposed solutions (part 1 and 2) is
progressing.[1]  But the final part (3) of his solution is also going to take
some work.

In Johns presentation he lists 3 alternatives for gup-pinned pages:

1) Hold off try_to_unmap
2) Allow writeback while pinned (via bounce buffers)
	[Note this will not work for DAX]
3) Use a "revocable reservation" (or lease) on those pages
4) Pin the blocks as busy in the FS allocator

The problem with lease's on pages used by RDMA is that the references to
these pages is not local to the machine.  Once the user has been given access
to the page they, through the use of a remote tokens, give a reference to that
page to remote nodes.  This is the core essence of RDMA, and like it or not,
something which is increasingly used by major Linux users.

Therefore we need to discuss the extent by which leases are appropriate and
what happens should a lease be revoked which a user does not respond to.

As John Hubbard put it:

"Other filesystem features that need to replace the page with a new one can
be inhibited for pages that are GUP-pinned. This will, however, alter and
limit some of those filesystem features. The only fix for that would be to
require GUP users monitor and respond to CPU page table updates. Subsystems
such as ODP and HMM do this, for example. This aspect of the problem is
still under discussion."

	-- John Hubbard[2]

The following people have been involved in previous conversations and would be key to
the face to face discussion.

John Hubbard
Jan Kara
Dave Chinner
Michal Hocko
Dan Williams
Matthew Wilcox
Jason Gunthorpe

Thank you,
Ira Weiny

[1] https://linuxplumbersconf.org/event/2/contributions/126/attachments/136/168/LPC_2018_gup_dma.pdf
[2] https://lkml.org/lkml/2019/2/4/7

