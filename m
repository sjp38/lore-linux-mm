Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8806C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:44:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9439D20851
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:44:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9439D20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 207F16B000D; Thu, 13 Jun 2019 03:44:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16ADB6B000E; Thu, 13 Jun 2019 03:44:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 009776B0010; Thu, 13 Jun 2019 03:44:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6226B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:44:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so29665738edc.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:44:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fPWJxUd91XkV8+RkKPG+Fp70LA51OC3b6DLb2awOmy8=;
        b=myAEUTZ+/25uVFvChuyM4DsuQrcjj48ailQn5LQbY4CsEquKjUUr7/+S3wQZ2wdB5K
         vg6Ud6yFTXWVp2woQOdaJwn+a12CtIIcwY2i7t0YsU4ijUl/3WdEYkbOT6JMYNb9kpOG
         7SgwzCvc2JZRjqrQK9jEM7txp6b4V5TwQO4BQb8OoUSpNfJDANWczwTR9W7TtWjXIay8
         z6bvECtfBpACC1xDh6Fv85MrQVv6Vgq9oUV9n25U+bgtEyYnuBThN6100m0HmI5qGqpN
         7Be0fX5Z3pek9rgwMnjOJd/DeVRJ/ccPwHyxwhix2BCIKRwjP2wC8F89EOH3cRm6QJdl
         sQJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAW7XgQtpMWAt+KgQFFe+JRmbcKFxunlG3hN7vks9GKyw8JxmEJm
	QWxMHdW7Lb3tH5qrR2vJbUcoIlYWRlIjEL6N1V+PXOFjUnhyh1qDC9mQ0MF6zJhRB8Pj3PoshS4
	AONuYG3s4MAaYRd3wsSl+CfioOTArnlRHLOq+nbSkEbiIAkcI6SLcgiWLCY5Qt9BYSw==
X-Received: by 2002:a17:906:1845:: with SMTP id w5mr14601721eje.0.1560411842144;
        Thu, 13 Jun 2019 00:44:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzv67J0oUjMc1pD6ZlmRzmzJOH1G4wNpEPPArLuGX39kKJSF5chqd9FkbqfAYt4NUeVHXls
X-Received: by 2002:a17:906:1845:: with SMTP id w5mr14601680eje.0.1560411841256;
        Thu, 13 Jun 2019 00:44:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560411841; cv=none;
        d=google.com; s=arc-20160816;
        b=ozRob44DAxFrLFbEcaBSysn7AenIHTfkH5SZ1FiJ8V6dqB/3Zd1GWA3MhOXpb/T3bV
         pTo6luocH6ENA/8Umqw3EBmIIFPx7ndtjak1rTQivDiMkKcU0UzrRwtNCPpp0XBK418P
         JOiDX2QNDWcRYck/n9XugiAI3NotGikyMacnX4aVGua4nrViMG6rUFLpmm4p6HHyurP0
         ttSIazERyhWuFj7iQd2lRRiEMawnMj2MP3EC+QW+RQekOEz86FWVhIoVq49UzHfDLZLI
         lgt93cwKbl60jpmfnSI1TmrZffFsq/bqk/37PT1u+mKEROmhtl9feG8f5PYD3oLlWXQK
         +i1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fPWJxUd91XkV8+RkKPG+Fp70LA51OC3b6DLb2awOmy8=;
        b=wrjSsJKNui0Sm+PihiLCmEPtNCQyS01KajQudt5/H1OUjHtBxInusTdfwnRt417oNP
         xabFcQR7yV2qr+8y8BzmN9aT1/uBTn7GZBPA2Sgbpawc8uzcl0tXmZlu3sijpxy9pzpk
         C9oZty73EXczoURhSxSULfsi27tPsfh4NffcBz6Gos9eJUYv+6XzJ/uRnvxoFjvwFBRq
         lbLiI2D22xmj+NeOdwkbjCPTAx8C/iRQzw5Wlpe+EeVEG4XJr94Lu7M4G0bczXpi8XRb
         CowLP+cB/EyTL9/DhI0ZIvEBDwDESeR/aCPgA6AGUVoTXdHR715dL9LBQ+NH1hLiYsbJ
         ehng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z51si1840952edz.300.2019.06.13.00.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 00:44:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 920EBAB91;
	Thu, 13 Jun 2019 07:44:00 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id B5C631E4328; Thu, 13 Jun 2019 09:43:59 +0200 (CEST)
Date: Thu, 13 Jun 2019 09:43:59 +0200
From: Jan Kara <jack@suse.cz>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, Theodore Ts'o <tytso@mit.edu>,
	Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs <linux-xfs@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	linux-ext4 <linux-ext4@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190613074359.GB26505@quack2.suse.cz>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz>
 <CAPcyv4jSyTjC98UsWb3-FnZekV0oyboiSe9n1NYDC2TSKAqiqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jSyTjC98UsWb3-FnZekV0oyboiSe9n1NYDC2TSKAqiqw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 12-06-19 11:49:52, Dan Williams wrote:
> On Wed, Jun 12, 2019 at 3:29 AM Jan Kara <jack@suse.cz> wrote:
> >
> > On Fri 07-06-19 07:52:13, Ira Weiny wrote:
> > > On Fri, Jun 07, 2019 at 09:17:29AM -0300, Jason Gunthorpe wrote:
> > > > On Fri, Jun 07, 2019 at 12:36:36PM +0200, Jan Kara wrote:
> > > >
> > > > > Because the pins would be invisible to sysadmin from that point on.
> > > >
> > > > It is not invisible, it just shows up in a rdma specific kernel
> > > > interface. You have to use rdma netlink to see the kernel object
> > > > holding this pin.
> > > >
> > > > If this visibility is the main sticking point I suggest just enhancing
> > > > the existing MR reporting to include the file info for current GUP
> > > > pins and teaching lsof to collect information from there as well so it
> > > > is easy to use.
> > > >
> > > > If the ownership of the lease transfers to the MR, and we report that
> > > > ownership to userspace in a way lsof can find, then I think all the
> > > > concerns that have been raised are met, right?
> > >
> > > I was contemplating some new lsof feature yesterday.  But what I don't
> > > think we want is sysadmins to have multiple tools for multiple
> > > subsystems.  Or even have to teach lsof something new for every potential
> > > new subsystem user of GUP pins.
> >
> > Agreed.
> >
> > > I was thinking more along the lines of reporting files which have GUP
> > > pins on them directly somewhere (dare I say procfs?) and teaching lsof to
> > > report that information.  That would cover any subsystem which does a
> > > longterm pin.
> >
> > So lsof already parses /proc/<pid>/maps to learn about files held open by
> > memory mappings. It could parse some other file as well I guess. The good
> > thing about that would be that then "longterm pin" structure would just hold
> > struct file reference. That would avoid any needs of special behavior on
> > file close (the file reference in the "longterm pin" structure would make
> > sure struct file and thus the lease stays around, we'd just need to make
> > explicit lease unlock block until the "longterm pin" structure is freed).
> > The bad thing is that it requires us to come up with a sane new proc
> > interface for reporting "longterm pins" and associated struct file. Also we
> > need to define what this interface shows if the pinned pages are in DRAM
> > (either page cache or anon) and not on NVDIMM.
> 
> The anon vs shared detection case is important because a longterm pin
> might be blocking a memory-hot-unplug operation if it is pinning
> ZONE_MOVABLE memory, but I don't think we want DRAM vs NVDIMM to be an
> explicit concern of the interface. For the anon / cached case I expect
> it might be useful to put that communication under the memory-blocks
> sysfs interface. I.e. a list of pids that are pinning that
> memory-block from being hot-unplugged.

Yes, I was thinking of memory hotplug as well. But I don't think the
distinction is really shared vs anon - a pinned page cache page can be
blocking your memory unplug / migration the same way as a pinned anon page.
So the information for a pin we need to convey is the "location of
resources" being pinned - that is pfn (both for DRAM and NVDIMM) - but then
also additional mapping information (which is filename for DAX page, not
sure about DRAM). Also a separate question is how to expose this
information so that it is efficiently usable by userspace. For lsof, a file
in /proc/<pid>/xxx with information would be probably the easiest to use
plus all the issues with file access permissions and visibility among
different user namespaces is solved out of the box. And I believe it would
be reasonably usable for memory hotplug usecase as well. A file in sysfs
would be OK for memory hotplug I guess, but not really usable for lsof and
so I'm not sure we really need it when we are going to have one in procfs.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

