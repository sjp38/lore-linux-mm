Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8D90C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:58:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94F0021872
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:58:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94F0021872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 453F68E004F; Thu,  7 Feb 2019 11:58:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B5CB8E0002; Thu,  7 Feb 2019 11:58:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 231108E004F; Thu,  7 Feb 2019 11:58:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3EED8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:57:59 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id p3so307523plk.9
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:57:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eQDWlgHViga2MpxDRvaRcn7gsyqV/GDUhUDUaM00s4I=;
        b=mf9wssI1pEXHGBaP7sGtrKm6WLkwPUFNkDMlLWNTb9R5Y/ivjXFvHDYZREVXMxMjDj
         8XvqIgYYEoR/pqXBU5HrJbmI61CwtGIshrIsV3LxN3owmtNTHL2oQd1eh0l1Ud/yihg4
         1geXeT4s1q4wFFenGXqnShHnfj7oT+Y2i+XpZkldhR36OhqY2SkKjmJpS9KeXJRwd8We
         O+mWKrBFiXDSkHpCONgJMpg4QuD5KHPuLxvfDD08kpJnyBnDmn8lHx+LatFb+3uTnyvi
         10DEMBRV3SLYbP5UtlVr8pXFHdjV48vWKrWDvHohgULmCJU0y1xrIRZ2M/bgB/gMNg8y
         9CTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY1ozvL2UTiQg1brKGYyzIATNI2Y8GFGHVDEp9+fDkENVuAOCM8
	k2fVEZVEb/FypeErqL3IaN6ZTORqGwKBrhs+6JLvt+7AooSo4+O098SB7XZfLqfti73wMW4ThoK
	R3eNWuCe0G2XTW/9sAGJqaJD1Iv+gQXd4ja34hH6HZ6Neghg0mLFsu6U9zbpGL4Zr0Q==
X-Received: by 2002:a17:902:a70b:: with SMTP id w11mr17384098plq.84.1549558679557;
        Thu, 07 Feb 2019 08:57:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iae3kY5dRlkOyXTHuojyYaPvGmD/DXqHjp5UBNooURem+072H4KGBpT/cCq3OjHA041vdtR
X-Received: by 2002:a17:902:a70b:: with SMTP id w11mr17384036plq.84.1549558678795;
        Thu, 07 Feb 2019 08:57:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549558678; cv=none;
        d=google.com; s=arc-20160816;
        b=bF/Rzsu8t5OKkztz/FGXF0j/DAGnVxNN7I2D7jVwJ6ypZtg9/XrBStM2AmjnZygkrg
         s22i0af8YF5GRQAnPO5XCfH30S09DBzTluXOjyAxUO3n/U+aHA2Yos8mN/v682VisUHc
         6exLvuRFPFSskvkMnY+ZVvAjfYFgyX9KvAplQBWefwADj8psghW8LpTnUHEBeuK/K5sB
         j9qLeobmaM2duzOReKBZ9KERL20DGVrPBcwzGDKh338JTU8byp65CW+hGgLGzHbM2BK1
         VoA4UfBGdVzW5IITeM+FHmPfa2PDHaGEZGtl6uBeH8IUZlpzRdBo6gVyHXine3T7nKP4
         VDJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eQDWlgHViga2MpxDRvaRcn7gsyqV/GDUhUDUaM00s4I=;
        b=0D/GwTvXs34Dje+dHk0PUdRSjgzwMHqsQVmzq3A7yHaFMAedqG6WdTVYO5DnqNJ3GG
         MEe1SSIzrHdbkYKHkvw/K2m8iTtl0WW9hS4nButYnLOENrgzMrj8Jw7x1hjfZX6Vg8OA
         lMXycqqf1WS4RoDJ25wO4bXH98iwHLvTaD2+n8pZhNWQtBMgb8bljEVQv1Rwmv6LKOmW
         h2mmCIBI4l7pTbr/bEfyWt4VJzE44gRgLjtWM9UxnIqCONyHmIDyiSnl+zpRLjluMJqf
         grk1+YfKUzVycdSDRCmAovVE2v7+mrkNM4AlD9zxj8dnb8MbHP1E8m+IHQjBbGxr5gJ5
         evnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d17si4792620pgp.274.2019.02.07.08.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 08:57:58 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Feb 2019 08:57:58 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,344,1544515200"; 
   d="scan'208";a="318468274"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 07 Feb 2019 08:57:57 -0800
Date: Thu, 7 Feb 2019 08:57:41 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Tom Talpey <tom@talpey.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Dave Chinner <david@fromorbit.com>,
	Doug Ledford <dledford@redhat.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>, linux-mm@kvack.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190207165740.GB29531@iweiny-DESK2.sc.intel.com>
References: <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard>
 <20190207052310.GA22726@ziepe.ca>
 <CC414509-F046-49E3-9D0C-F66FD488AC64@oracle.com>
 <6b260348-966a-bc95-162b-44ae8265cf03@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6b260348-966a-bc95-162b-44ae8265cf03@talpey.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 10:28:05AM -0500, Tom Talpey wrote:
> On 2/7/2019 10:04 AM, Chuck Lever wrote:
> > 
> > 
> > > On Feb 7, 2019, at 12:23 AM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > 
> > > On Thu, Feb 07, 2019 at 02:52:58PM +1100, Dave Chinner wrote:
> > > 
> > > > Requiring ODP capable hardware and applications that control RDMA
> > > > access to use file leases and be able to cancel/recall client side
> > > > delegations (like NFS is already able to do!) seems like a pretty
> > > 
> > > So, what happens on NFS if the revoke takes too long?
> > 
> > NFS distinguishes between "recall" and "revoke". Dave used "recall"
> > here, it means that the server recalls the client's delegation. If
> > the client doesn't respond, the server revokes the delegation
> > unilaterally and other users are allowed to proceed.
> 
> The SMB3 protocol has a similar "lease break" mechanism, btw.
> 
> SMB3 "push mode" has long-expected to allow DAX mapping of files
> only when an exclusive lease is held by the requesting client.
> The server may recall the lease if the DAX mapping needs to change.
> 
> Once local (MMU) and remote (RDMA) mappings are dropped, the
> client may re-request that the server reestablish them. No
> connection or process is terminated, and no data is silently lost.

How long does one wait for these remote mappings to be dropped?

Ira

