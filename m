Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65608C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:11:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15027214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:11:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15027214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C1FD8E0003; Tue, 12 Mar 2019 18:11:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 970478E0002; Tue, 12 Mar 2019 18:11:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85FA28E0003; Tue, 12 Mar 2019 18:11:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 464D48E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:11:18 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a6so4195888pgj.4
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:11:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GEIKmcExN+Zquuo05O2/aPZaWJFBJQet5aCFI200gKE=;
        b=NFscUEQA3n/3O7i8RSi0KlZFb0FRXOuAJrQi//JeUwusNQQbB58BQAqPUKD81FFzUf
         eosxs01kHnT93k6UQebJpMlkVI0sEgSebCRQdNXt0nSXBfH0N5jVm22jdAcMvIwND36z
         uam2HwTKD6gxRDU1OVZShlwuclPJnQmB8Bk1KTgEDD1p9LZZ1K/D/nsgFA74nW2EapKS
         H5ZwXgR8VXO4zEtCG6ZBCorw6s5eOXq9V51WCfkfOfE//yp0Np3aW0PyPimp5ceMEX2Y
         l2nyixqhKV5WaCMyt5hMKRUkg1JXOslnouH2NIX0PiUtT2E2yd4HqcJ585VjY91As+cH
         n6EQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWIbv/Rv1HJmnDrHCh6DYRw+G5+HussfVaQVD7R3Ye7tyDMIgur
	aYAvKl33W3tKS5yR4neMITQARVQEqJrfHlpmIDPU0nzxWj6aDZOVj92Czgl+lkcEJO0PX+55nDA
	Cap04koQdrYrvSnMEZJvPp4sKp9NrfqbQVhYwWQG6svdvvQLI/UzBB2gdfQDpgak=
X-Received: by 2002:a17:902:9304:: with SMTP id bc4mr42916878plb.81.1552428677958;
        Tue, 12 Mar 2019 15:11:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxC1vLNeZIW3JbssXCsxfDYHPcCLp2wT/P8wpXz6+VO31d/S0E9OL6rxIYzxt9SCQjIxPAO
X-Received: by 2002:a17:902:9304:: with SMTP id bc4mr42916813plb.81.1552428676921;
        Tue, 12 Mar 2019 15:11:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428676; cv=none;
        d=google.com; s=arc-20160816;
        b=MJrRs1HJciQIx685GnUnvQC7DBjKoRPummQ237jqvcOBma+fCbmePNmUHwR5MU8/3a
         PbaD1owGA8vIxjD2OOveDDgEUqjonHW+lWLJ5aGpcziOKHVHVUpXTdSYwSHimg49GxR0
         n1w5fVBeBHcV+Yg+mM1RuS9QgHrgYNM8rP8WZ3DVH2fc1D5I9VkfrKiryW5hx81CoTfF
         Dm83MiXLkJzopZtVir3X0p53ZfsYLsrSr40S0AC8gN1rcIcbpnvfqivay8FfmgSlfdjH
         233lLIB8LTle1rih2lwHILD/TvGN0QHeLxTlYsiqw9CwICDZ3xGOvfYzU3enKIVqBhwB
         REQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GEIKmcExN+Zquuo05O2/aPZaWJFBJQet5aCFI200gKE=;
        b=BhlOMTVc2dVH5l9gQvKGZRNnW36XsBTNRJE8LIq1oM1rIf8PdyoI+EpM9RFeFkKWCr
         FX493XuyqDMjS+C9AH3KLbgufwkJLQnNM97RE9BK14swpmB8Y+sWEH+NdpAYdxu+KMwF
         Gb2MIbqbDnfjIzV6ityjYkSMwwZNyx+GOL1ovEtus1m2umA5AmJVtjITsPuYkV2BD8jZ
         T+rERM1hCNcYYCFGiQ8EgJDgW6JQY4tN9+b3XqircxeruM5fjlEeXOd+aIEqfqBSEVJB
         VXG3lBw7tVVO3ZR+1SBVONkb6pCCzVE7cCEMllh056exwcmtxdMdLHN0pAI9W5d4BGkJ
         QX1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id q63si9122329pfb.154.2019.03.12.15.11.15
        for <linux-mm@kvack.org>;
        Tue, 12 Mar 2019 15:11:16 -0700 (PDT)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 13 Mar 2019 08:41:14 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1h3pc9-0001Zt-4k; Wed, 13 Mar 2019 09:11:13 +1100
Date: Wed, 13 Mar 2019 09:11:13 +1100
From: Dave Chinner <david@fromorbit.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Christopher Lameter <cl@linux.com>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190312221113.GF23020@dastard>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190310224742.GK26298@dastard>
 <01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@email.amazonses.com>
 <20190312103932.GD1119@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312103932.GD1119@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 03:39:33AM -0700, Ira Weiny wrote:
> IMHO I don't think that the copy_file_range() is going to carry us through the
> next wave of user performance requirements.  RDMA, while the first, is not the
> only technology which is looking to have direct access to files.  XDP is
> another.[1]

Sure, all I doing here was demonstrating that people have been
trying to get local direct access to file mappings to DMA directly
into them for a long time. Direct Io games like these are now
largely unnecessary because we now have much better APIs to do
zero-copy data transfer between files (which can do hardware offload
if it is available!).

It's the long term pins that RDMA does that are the problem here.
I'm asssuming that for XDP, you're talking about userspace zero copy
from files to the network hardware and vice versa? transmit is
simple (read-only mapping), but receive probably requires bpf
programs to ensure that data (minus headers) in the incoming packet
stream is correctly placed into the UMEM region?

XDP receive seems pretty much like the same problem as RDMA writes
into the file. i.e.  the incoming write DMAs are going to have to
trigger page faults if the UMEM is a long term pin so the filesystem
behaves correctly with this remote data placement.  I'd suggest that
RDMA, XDP and anything other hardware that is going to pin
file-backed mappings for the long term need to use the same "inform
the fs of a write operation into it's mapping" mechanisms...

And if we start talking about wanting to do peer-to-peer DMA from
network/GPU device to storage device without going through a
file-backed CPU mapping, we still need to have the filesystem
involved to translate file offsets to storage locations the
filesystem has allocated for the data and to lock them down for as
long as the peer-to-peer DMA offload is in place.  In effect, this
is the same problem as RDMA+FS-DAXs - the filesystem owns the file
offset to storage location mapping and manages storage access
arbitration, not the mm/vma mapping presented to userspace....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

