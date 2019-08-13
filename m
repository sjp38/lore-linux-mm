Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79F07C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 18:00:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 291FA20679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 18:00:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="JkdPDFhK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 291FA20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B945B6B0005; Tue, 13 Aug 2019 14:00:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B44546B0006; Tue, 13 Aug 2019 14:00:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A338B6B0007; Tue, 13 Aug 2019 14:00:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0248.hostedemail.com [216.40.44.248])
	by kanga.kvack.org (Postfix) with ESMTP id 7FDC36B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:00:25 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2E411180AD801
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 18:00:25 +0000 (UTC)
X-FDA: 75818169210.03.head56_2098413f1d022
X-HE-Tag: head56_2098413f1d022
X-Filterd-Recvd-Size: 4848
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 18:00:23 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id b11so7470310qtp.10
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:00:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IBxnXq2Ic/FEKXbpZLemvQFxGE32/we3wuo4f4S9MyU=;
        b=JkdPDFhKWlCBD9Qi7RNp1yC1abkdUc7/1dY6LV39VmLNemSn9Powu35LNiuyO8uczt
         Nadnkpe9izQcaWOyGGeQHJ23tWPRR6bGmsg+cyaAilqF+z1rDRrm+slvgHjrpOBu79SN
         04/Y6/+5Ps6m17X0m+HDUinYIh8C32SkpSSPGyvi4DXoJS3WXfpvU9blzoRZ5bcDgJEL
         IDg+rbA5MUkHi8mQ00jNvvGVGA9O50CHREVVTEuNyId2Vgr0BUJk+6udZ7yoDqN0JsU4
         gZy0AfBcuVAFDG6OCN/ZVHt5uncO6CdDnK24oMMrw6a/bv0Qfkyj1OjJY0s/rkuU/UyI
         PpFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=IBxnXq2Ic/FEKXbpZLemvQFxGE32/we3wuo4f4S9MyU=;
        b=c3+8AEdILzY8y2Ik3xg8fhUHKu+Cdhn4gicn1yskYThSwhv0no9zLwrD6iLJTyx5pD
         Gn8gUIxlvSONb0oxn+Y2WS8GWHgtXo8p2SHhSDsXgnEuUyLlQ0eHSf1Oyrd71jN1I1p8
         R52S+qMJ2DLCtub8bPNCuxdqBJxH9+XBvgKczrXRblNHrqHP87BbG/Ij/N8W8iRDA2Qm
         QKF8LPkFQrCFM4y8hSqat7jh+IxphJKCFMB9kIATvTfHPvQ2HSKq3XcapJlq3sLdNqja
         0qyxr7aIE3B/sU7bf0xV1Gy1nP44V5tUGse3QTn4qMbuD9ANIJbq+MElpTty3mnA67v2
         A3rw==
X-Gm-Message-State: APjAAAWLgfUKiAYhnLV/HiGHb8ZZdy87Gj7Wq1wK1SnuqdHFwiRHBATS
	XM/8iioeGkCWfO1qgycXMJneEw==
X-Google-Smtp-Source: APXvYqwwH31e/CxiSAwLKzyYNpXPBlqnkZplwVbsfv2VH9N4iB3HSg736Ni8yTKYk8KDSLHvJDt7lg==
X-Received: by 2002:ac8:1a6c:: with SMTP id q41mr32662928qtk.217.1565719223137;
        Tue, 13 Aug 2019 11:00:23 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id y204sm5010562qka.54.2019.08.13.11.00.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Aug 2019 11:00:22 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hxb5q-0000sY-7l; Tue, 13 Aug 2019 15:00:22 -0300
Date: Tue, 13 Aug 2019 15:00:22 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 16/19] RDMA/uverbs: Add back pointer to system
 file object
Message-ID: <20190813180022.GF29508@ziepe.ca>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-17-ira.weiny@intel.com>
 <20190812130039.GD24457@ziepe.ca>
 <20190812172826.GA19746@iweiny-DESK2.sc.intel.com>
 <20190812175615.GI24457@ziepe.ca>
 <20190812211537.GE20634@iweiny-DESK2.sc.intel.com>
 <20190813114842.GB29508@ziepe.ca>
 <20190813174142.GB11882@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813174142.GB11882@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 10:41:42AM -0700, Ira Weiny wrote:

> And I was pretty sure uverbs_destroy_ufile_hw() would take care of (or ensure
> that some other thread is) destroying all the MR's we have associated with this
> FD.

fd's can't be revoked, so destroy_ufile_hw() can't touch them. It
deletes any underlying HW resources, but the FD persists.
 
> > This is why having a back pointer like this is so ugly, it creates a
> > reference counting cycle
> 
> Yep...  I worked through this...  and it was giving me fits...
> 
> Anyway, the struct file is the only object in the core which was reasonable to
> store this information in since that is what is passed around to other
> processes...

It could be passed down in the uattr_bundle, once you are in file operations
handle the file is guarenteed to exist, and we've now arranged things
so the uattr_bundle flows into the umem, as umems can only be
established under a system call.

Jason

