Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B878AC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:18:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D7522063F
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:18:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lpafWUUx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D7522063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F24748E0002; Thu, 13 Jun 2019 13:18:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAC838E0001; Thu, 13 Jun 2019 13:18:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4D178E0002; Thu, 13 Jun 2019 13:18:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B42C08E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:18:36 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so18074078qtb.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:18:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ECRuDs1AAJXccME5fjhnIagUHhl7wP1zzfkz6zfy+gs=;
        b=c1+5/kgJIB4+6EmYbtodx2zJlvB3T1knDk0+9nT44dnrZTJqUFxiBEiwQmYP7BGDGC
         aQ+rjq2/nncJ+/86ZX9QdeOfkORSTDpFIRiu3bxp7rzf3mUd142BrDPQTJqkpRPqauqR
         K5b36BMVdwH/Nvxc/UMAYXLPCM2mgjAMR9iB66UYp3Htux8wurIEY421Nqw8/kbR7Jnw
         npYfU/FASw4t+GbVStSRAMTjNKH9NuxPxb2vjtuWOAfMbIewRgumnezB3u6Hs/F8/is7
         K/ZEHvHu5/ITm0wxwUj5xQQM4rfkBx3IIPR3m9Fw7ai6sxAfCMbkPEAAF7vYsXBuemaL
         crTA==
X-Gm-Message-State: APjAAAVwlQ/Wu9A/zrmNeVHhpPHtDq3S6UmjdvSzXLvJdiha7IdjINiW
	jMFUFW4GqL66917Qc4yO91NPfJPlIp/+3zlqcGxXPOq3R3jxH2lDsCijUpfO3iKz5KEwbIg8N/d
	ADvZ2eBfSZVFM9bdevqpffjJfUGbfvDtpkKOH/xjSUhURshicNpKHgzz7g+jV/LUcXA==
X-Received: by 2002:a37:aac5:: with SMTP id t188mr71497206qke.157.1560446316360;
        Thu, 13 Jun 2019 10:18:36 -0700 (PDT)
X-Received: by 2002:a37:aac5:: with SMTP id t188mr71497175qke.157.1560446315685;
        Thu, 13 Jun 2019 10:18:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560446315; cv=none;
        d=google.com; s=arc-20160816;
        b=Z6G3MnugAnWtBvtFxOCd32mcB9DMCeV4QDUHq6K6b7Z9l9j5PNQSSgaWdCRopzkN0c
         OJR5SBn7oPjlnMRi/dwJp+LXbhi+/UUr9jRdQ2HeyzMirAR6/GV6eVentS3jkZRa6aAq
         MD1cOZyGkPUbAFK4OkZjc9ZKZXVM9k+QseECbGD4SMJd+ER58Z58S7l7Ym07DT65OdQY
         Nz5MFXmJyX47CuxLg37HlgApN6uHO++EHnqyzSxLUfGYkQMvl2XB+2CuNVwqeQcj4pj9
         hOW5+726aXu6unpijtU0TVj+Fb0R+Dc8UjIXQLz45H62t3S6dTKKgT++4gbylDgbdUYu
         IJBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ECRuDs1AAJXccME5fjhnIagUHhl7wP1zzfkz6zfy+gs=;
        b=p7tQaww2slJEtmgk5gAVOb/JCKJF3ZBGtWnlfXLhNuOjIskrqIMbLw2EDlyTOu6Eag
         3AesEN+zWL8g0ppmUW4U/EYCu2tKH8PPaS5c+drlTHdeIPqLRxgWRzYCfr5j9uXoG9//
         NNwq4ru7uHC7NOUrAi0s9e7+ZtCi4ApKj/y52e1hmQVlkotS945xAmaB+gNUV5uE42M3
         QEOmDBuPIbZbZXdF7bZeysHEH/FbimvmdOAwIBTpBg5RTpVjOmJ29UHlvNYwnTZ8BEd8
         8cG+neNk0751pZUQs4D92VVGP4mxokEkBHLVipc9eiZhSISRhgBNzCqmDUkIOLl/NGIE
         Wk9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lpafWUUx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a38sor971334qte.32.2019.06.13.10.18.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 10:18:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lpafWUUx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ECRuDs1AAJXccME5fjhnIagUHhl7wP1zzfkz6zfy+gs=;
        b=lpafWUUxvoz6cw8t6bvxhkbpKx1MuDJC/6+rsfIk9kELesUHNICDeurjA/f9ZuoaJv
         lKvrldgcxc6rNvpGlf+9lPT2riW0RE1+HuS2OqxKuK9J/UHHXstRF22tdIYHVfy+KlvT
         LRXs02nEuzM/Fk4kx+1bbgAFr8bE6dMuPmxEyYZicAywAmS5YuFqquENcwoxV3ALaTJr
         wrm1jUeHUGOSNU/aAA8xVX35TgozP9YEYH5RVAbReFiyARjThtZ1Rs+sS5w3QP1kXXnb
         Bg53NxX8LuVo7QxF8lvDT58SoxeM97wjJy7wRjhtAvG+RnkgIyeQxLZquacOghksiJH/
         /FWA==
X-Google-Smtp-Source: APXvYqxo9wZDsL+u9xxF1oR9luzN2plR83tNtwXpM5LjZTCeK+hD6TjhoexGVCwTWwyvS0UUHoLRyg==
X-Received: by 2002:aed:3686:: with SMTP id f6mr53799960qtb.30.1560446315300;
        Thu, 13 Jun 2019 10:18:35 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id l3sm76969qkd.49.2019.06.13.10.18.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 10:18:34 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbTMw-000325-3P; Thu, 13 Jun 2019 14:18:34 -0300
Date: Thu, 13 Jun 2019 14:18:34 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs <linux-xfs@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	linux-ext4 <linux-ext4@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190613171834.GE22901@ziepe.ca>
References: <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca>
 <20190612120907.GC14578@quack2.suse.cz>
 <20190612191421.GM3876@ziepe.ca>
 <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
 <CAPcyv4gkksnceCV-p70hkxAyEPJWFvpMezJA1rEj6TEhKAJ7qQ@mail.gmail.com>
 <20190612233324.GE14336@iweiny-DESK2.sc.intel.com>
 <CAPcyv4jf19CJbtXTp=ag7Ns=ZQtqeQd3C0XhV9FcFCwd9JCNtQ@mail.gmail.com>
 <20190613151354.GC22901@ziepe.ca>
 <CAPcyv4hZsxd+eUrVCQmm-O8Zcu16O5R1d0reTM+JBBn7oP7Uhw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hZsxd+eUrVCQmm-O8Zcu16O5R1d0reTM+JBBn7oP7Uhw@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 09:25:54AM -0700, Dan Williams wrote:
> On Thu, Jun 13, 2019 at 8:14 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Wed, Jun 12, 2019 at 06:14:46PM -0700, Dan Williams wrote:
> > > > Effectively, we would need a way for an admin to close a specific file
> > > > descriptor (or set of fds) which point to that file.  AFAIK there is no way to
> > > > do that at all, is there?
> > >
> > > Even if there were that gets back to my other question, does RDMA
> > > teardown happen at close(fd), or at final fput() of the 'struct
> > > file'?
> >
> > AFAIK there is no kernel side driver hook for close(fd).
> >
> > rdma uses a normal chardev so it's lifetime is linked to the file_ops
> > release, which is called on last fput. So all the mmaps, all the dups,
> > everything must go before it releases its resources.
> 
> Oh, I must have missed where this conversation started talking about
> the driver-device fd. 

In the first paragraph above where Ira is musing about 'close a
specific file', he is talking about the driver-device fd.

Ie unilaterally closing /dev/uverbs as a punishment for an application
that used leases wrong: ie that released its lease with the RDMA is
still ongoing. 

Jason

