Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25058C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:34:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D86572166E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:34:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D86572166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C7346B000A; Fri,  9 Aug 2019 04:34:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 451326B000C; Fri,  9 Aug 2019 04:34:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F25D6B000D; Fri,  9 Aug 2019 04:34:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D4B7D6B000A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:34:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y15so59865782edu.19
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:34:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kgiw5Cji98WMk6VDWcJJy9y09PBoa5RzeKwnPSCfYKM=;
        b=cLkZPb2vm+TqePIm3woWyu8GMWDODU7Puz2oOMhm999w6B2geXSy/tKYaDyYyCt380
         9D4OLsBCsCT8mJHezoUPrvNSNJ8Na6M2dfErwgG7fCDgSKVcZ3X/TojSHjjiFpBt2BLh
         5zoHkJuLDSEzvnPS5i98fCfD/QX0xzo/zD5QifQWBk0HQK9IEPhTb1xGVEfu4pA9YCs9
         vOBKSeJS7EsrusRQWAWGeiPgFpbfevjX6c6LOGC0ua3+/YNNT3Q+8Y1QY0byPnrCZ2qq
         v5O4lQI4LYgfaMo4nWHYqXGlZ/pEQLpuU6u2+4e7yTZ9yZgnSjqx1HVoAYbYLvFSHdjg
         1QSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVCiWV6iRk5uRAisVVDGTEdydkgSFTFOl8W1UzmsALBcDxJK8BO
	bHfmmBiCCdlVggs/FMo1OkvigeJQN62apc4WkHLum6tT6JYvdQxBpcUqhZauCRabUi3vV9Sqldv
	bFLRGAIEDXXx2zjNcr/BTjFdcTfvm13H2JDu4Y9zpkfFixU3wd8Rw1wDJ9KB4k2a2rg==
X-Received: by 2002:a50:eb0b:: with SMTP id y11mr20465330edp.224.1565339678428;
        Fri, 09 Aug 2019 01:34:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiOjqxIJKZ9dTN/c8HGsDWnFQ9JgRxVSi5MUgp68swf38eLnjjNENSHtb3tmB67vkYB48b
X-Received: by 2002:a50:eb0b:: with SMTP id y11mr20465274edp.224.1565339677623;
        Fri, 09 Aug 2019 01:34:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565339677; cv=none;
        d=google.com; s=arc-20160816;
        b=aksw/ozvlVn/qH8ONKN6o+o0NVpnv0OSh5/FH6cHtDA+UJ8sVSQBVyURtTt7q4yKtp
         XDdDFHlrtxRlhExGmjs23/qK4F6Dykwg++sudZmhWU/QtwwB8zKJ6hhZ82MCtix0ZvmJ
         34NnU/aMnEMwaVd/7wN1n/2usdXgFDF7xMflb/6OuX8H36PsFsfJDXSTA9gIQPOiv8t7
         iig/uzZzdKykj/DvuKwsl8JHDhpC/IcZnQR+uf3MTTZWbmxrNpbIVK6HfCkHT9f0o19C
         g2C1LPe/8vxPvBdLFqYp7/jXoEWjSj2+pZ9hNuaUfxKjhTVh12dFxb4JZO2ARQiQAlqb
         HJjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kgiw5Cji98WMk6VDWcJJy9y09PBoa5RzeKwnPSCfYKM=;
        b=yb9UO6kmNkXuav9g/wvkF/ILbIobyohmLRIYppMmaTjGPFDWCC1KrYzb6AifUXTkP4
         W8NhoWDc43mreyRFE2+MKXnLxo41dhLRgjiNrB99t5Wj+gFIXEvVHaFWO9mLaDhckxXD
         5RapKOJDLArYnm9X8wC8h0zhdj6kZ+mXJu/mv5B1OZs8tX/HCPxguWazg30hvQ0gJMvh
         t8aVw0BDAysy7G7r6DABB4wddECrQPe7slriJ/oxDc+LkD7/hihrIoZdLyol1VUxcJSP
         yAZD6rGy+YODrF0bvCIyriZ4NrRep7t+3WAidch/r1X585GIuvsW+bIN5D5PpClN6zYB
         h4jw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j30si44483982eda.52.2019.08.09.01.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:34:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DD89FAE49;
	Fri,  9 Aug 2019 08:34:36 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id DC04B1E437E; Fri,  9 Aug 2019 10:34:35 +0200 (CEST)
Date: Fri, 9 Aug 2019 10:34:35 +0200
From: Jan Kara <jack@suse.cz>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>,
	John Hubbard <jhubbard@nvidia.com>,
	Matthew Wilcox <willy@infradead.org>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mm@kvack.org, linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, sparclinux@vger.kernel.org,
	x86@kernel.org, xen-devel@lists.xenproject.org
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Message-ID: <20190809083435.GA17568@quack2.suse.cz>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802091244.GD6461@dhcp22.suse.cz>
 <20190802124146.GL25064@quack2.suse.cz>
 <20190802142443.GB5597@bombadil.infradead.org>
 <20190802145227.GQ25064@quack2.suse.cz>
 <076e7826-67a5-4829-aae2-2b90f302cebd@nvidia.com>
 <20190807083726.GA14658@quack2.suse.cz>
 <20190807084649.GQ11812@dhcp22.suse.cz>
 <20190808023637.GA1508@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808023637.GA1508@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 07-08-19 19:36:37, Ira Weiny wrote:
> On Wed, Aug 07, 2019 at 10:46:49AM +0200, Michal Hocko wrote:
> > > So I think your debug option and my suggested renaming serve a bit
> > > different purposes (and thus both make sense). If you do the renaming, you
> > > can just grep to see unconverted sites. Also when someone merges new GUP
> > > user (unaware of the new rules) while you switch GUP to use pins instead of
> > > ordinary references, you'll get compilation error in case of renaming
> > > instead of hard to debug refcount leak without the renaming. And such
> > > conflict is almost bound to happen given the size of GUP patch set... Also
> > > the renaming serves against the "coding inertia" - i.e., GUP is around for
> > > ages so people just use it without checking any documentation or comments.
> > > After switching how GUP works, what used to be correct isn't anymore so
> > > renaming the function serves as a warning that something has really
> > > changed.
> > 
> > Fully agreed!
> 
> Ok Prior to this I've been basing all my work for the RDMA/FS DAX stuff in
> Johns put_user_pages()...  (Including when I proposed failing truncate with a
> lease in June [1])
> 
> However, based on the suggestions in that thread it became clear that a new
> interface was going to need to be added to pass in the "RDMA file" information
> to GUP to associate file pins with the correct processes...
> 
> I have many drawings on my white board with "a whole lot of lines" on them to
> make sure that if a process opens a file, mmaps it, pins it with RDMA, _closes_
> it, and ummaps it; that the resulting file pin can still be traced back to the
> RDMA context and all the processes which may have access to it....  No matter
> where the original context may have come from.  I believe I have accomplished
> that.
> 
> Before I go on, I would like to say that the "imbalance" of get_user_pages()
> and put_page() bothers me from a purist standpoint...  However, since this
> discussion cropped up I went ahead and ported my work to Linus' current master
> (5.3-rc3+) and in doing so I only had to steal a bit of Johns code...  Sorry
> John...  :-(
> 
> I don't have the commit messages all cleaned up and I know there may be some
> discussion on these new interfaces but I wanted to throw this series out there
> because I think it may be what Jan and Michal are driving at (or at least in
> that direction.
> 
> Right now only RDMA and DAX FS's are supported.  Other users of GUP will still
> fail on a DAX file and regular files will still be at risk.[2]
> 
> I've pushed this work (based 5.3-rc3+ (33920f1ec5bf)) here[3]:
> 
> https://github.com/weiny2/linux-kernel/tree/linus-rdmafsdax-b0-v3
> 
> I think the most relevant patch to this conversation is:
> 
> https://github.com/weiny2/linux-kernel/commit/5d377653ba5cf11c3b716f904b057bee6641aaf6
> 
> I stole Jans suggestion for a name as the name I used while prototyping was
> pretty bad...  So Thanks Jan...  ;-)

For your function, I'd choose a name like vaddr_pin_leased_pages() so that
association with a lease is clear from the name :) Also I'd choose the
counterpart to be vaddr_unpin_leased_page[s](). Especially having put_page in
the name looks confusing to me...

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

