Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBE30C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:23:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90A502084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:23:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="MFiCvrWu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90A502084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DCF86B0005; Wed, 14 Aug 2019 08:23:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08E426B0006; Wed, 14 Aug 2019 08:23:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC0466B0007; Wed, 14 Aug 2019 08:23:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0192.hostedemail.com [216.40.44.192])
	by kanga.kvack.org (Postfix) with ESMTP id CBB526B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:23:11 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 678CA181AC9B4
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:23:11 +0000 (UTC)
X-FDA: 75820948182.29.girls77_38e49b57ddd23
X-HE-Tag: girls77_38e49b57ddd23
X-Filterd-Recvd-Size: 6071
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:23:10 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id e8so9320735qtp.7
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 05:23:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FsrM9iQimb3FYscqsqAsnH27bNwSQwrEhuf8y7pTQg4=;
        b=MFiCvrWusQBCqyuv0MsnT3yWbG9zhhmIK7HccUs0r5kMXPkuqKNunVQ1h/zORuyu1K
         dPCooMZtmzJUb73IhrAfW/RZn4uYi3/BcDXSM/JcFnAxpkgDO1ZnxF/dhwE9LrJIMKK2
         GIj2ajzFnej54EdngHyC+E8SXNY43OW5hl/3FkeZd7g7YORhHWyVwCG9TQ3dfsA80OiH
         HWrzFKQ3z7OgUVHt5oT61jV6sjY3dSq3dQapXw9as/49/pFairabCCHK8rm27pDfH41T
         89o7Sbf/Wh6HwQkqcQV3HvbMUxSx6Ms+71YocGCgvEMjq5pAvY9mDNWZDltPkDZJ4FU7
         pvDQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=FsrM9iQimb3FYscqsqAsnH27bNwSQwrEhuf8y7pTQg4=;
        b=N137UnOcX1vTlLMltVvwAQ7oHQHNxnnGXlc3IrYuBpy+dZFwDpqFXPYRWGNXxaW0Ib
         tpB4wTBsdIYchvN8I6wZR4dJRnhOjL1zP0dec7e+8PZrWX2/Tvi9B/OgufkQmsFMXJXA
         KkINheQRS9Pmv2nMWy0O/mYO3Ve7T7JaJbQLmq4yTVsHYqNlLnO1YHQ8YS06cN09Ju/5
         LpPHqk6Cud3nFlBCN7DzOWb5VM/wXCWlR6747rOKunhnM2IEbI6tC0BMIctnsGCJRUtk
         pSLNbi25KgtOQM5uZXgonQecVdUQDzaCw6sJs6LdByd5FxzYfPh112L29lo8jB9xwf3c
         9H7g==
X-Gm-Message-State: APjAAAXvZ/X8zDPaXq39+hqs5ag7BdPhSQiOgx8WomP3fU/zbx8dlnRA
	IJhK2kZ+b9ynwrJG2xvUbZkIHw==
X-Google-Smtp-Source: APXvYqzonRYXwuBtV/92ARGeHeTsDCMwXjWO17US6GUvZqwZjITlYGafac4H3tDArYgjya/pKX0Bmw==
X-Received: by 2002:a0c:fe6b:: with SMTP id b11mr2192818qvv.64.1565785390263;
        Wed, 14 Aug 2019 05:23:10 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id e7sm46275956qtp.91.2019.08.14.05.23.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 05:23:09 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hxsJ2-00049A-QU; Wed, 14 Aug 2019 09:23:08 -0300
Date: Wed, 14 Aug 2019 09:23:08 -0300
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
Message-ID: <20190814122308.GB13770@ziepe.ca>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-17-ira.weiny@intel.com>
 <20190812130039.GD24457@ziepe.ca>
 <20190812172826.GA19746@iweiny-DESK2.sc.intel.com>
 <20190812175615.GI24457@ziepe.ca>
 <20190812211537.GE20634@iweiny-DESK2.sc.intel.com>
 <20190813114842.GB29508@ziepe.ca>
 <20190813174142.GB11882@iweiny-DESK2.sc.intel.com>
 <20190813180022.GF29508@ziepe.ca>
 <20190813203858.GA12695@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813203858.GA12695@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 01:38:59PM -0700, Ira Weiny wrote:
> On Tue, Aug 13, 2019 at 03:00:22PM -0300, Jason Gunthorpe wrote:
> > On Tue, Aug 13, 2019 at 10:41:42AM -0700, Ira Weiny wrote:
> > 
> > > And I was pretty sure uverbs_destroy_ufile_hw() would take care of (or ensure
> > > that some other thread is) destroying all the MR's we have associated with this
> > > FD.
> > 
> > fd's can't be revoked, so destroy_ufile_hw() can't touch them. It
> > deletes any underlying HW resources, but the FD persists.
> 
> I misspoke.  I should have said associated with this "context".  And of course
> uverbs_destroy_ufile_hw() does not touch the FD.  What I mean is that the
> struct file which had file_pins hanging off of it would be getting its file
> pins destroyed by uverbs_destroy_ufile_hw().  Therefore we don't need the FD
> after uverbs_destroy_ufile_hw() is done.
> 
> But since it does not block it may be that the struct file is gone before the
> MR is actually destroyed.  Which means I think the GUP code would blow up in
> that case...  :-(

Oh, yes, that is true, you also can't rely on the struct file living
longer than the HW objects either, that isn't how the lifetime model
works.

If GUP consumes the struct file it must allow the struct file to be
deleted before the GUP pin is released.

> The drivers could provide some generic object (in RDMA this could be the
> uverbs_attr_bundle) which represents their "context".

For RDMA the obvious context is the struct ib_mr *

> But for the procfs interface, that context then needs to be associated with any
> file which points to it...  For RDMA, or any other "FD based pin mechanism", it
> would be up to the driver to "install" a procfs handler into any struct file
> which _may_ point to this context.  (before _or_ after memory pins).

Is this all just for debugging? Seems like a lot of complication just
to print a string

Generally, I think you'd be better to associate things with the
mm_struct not some struct file... The whole design is simpler as GUP
already has the mm_struct.

Jason

