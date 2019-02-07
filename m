Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 467E3C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 18:17:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD6A02086C
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 18:17:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="B47/aMZw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD6A02086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37DE98E0059; Thu,  7 Feb 2019 13:17:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 307B18E0002; Thu,  7 Feb 2019 13:17:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CEB08E0059; Thu,  7 Feb 2019 13:17:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E737B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 13:17:47 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id c84so650274qkb.13
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 10:17:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=DxakVmrk+rxFQSFA39vWF6fSPdcTuwBUfQ7c7/5uFy0=;
        b=mfgWRn9z+PxJvkq7nMZLOHiI0TzoWmjODDkYPUOWZTSxh+iJ5TJPRhuzU0fMor6EHr
         MCvupbOIZlhIUN2kbGByVDh9ZaAfo/ctf1iSmB50/xbitN2vgBGmFHPTVrNlksEPZ6AU
         +T8h3oEosnqWOCdmGeLwRp4XOclN3O4f52s5ZK+OPxORWbK4OIi1CLuJqZOanLwX64md
         g4vh79IPLUzq062L4TJib/88D0CeWOUm2vpqTNvyQxtrNbcnZDOcyRJwN4GPWqSaXzFn
         EP0dy5TAIXxN2ZxoiBpqmbiQWiA+DeJkmxYSvRt+v6yxIfV5WXDwNRhTh1XiFn8brPV2
         unRQ==
X-Gm-Message-State: AHQUAuYsrMRElbkQHVDvgrnUujPBqBl5Zx9O+BpDs6EPPpsbKYm0em4f
	c/v4jwfg/i3i0rAD1EbuVwQXNoUvBLhaYW8G6GmMJeEkQr0GdNmjSYGqbHMoT/QQUuMB3LjSgpZ
	YCxvqqigI/vmeYoqqJRY3TXUDHb7LRgJOI4v1WE440T0QQ7uf6VuGto+BJnR3BNo=
X-Received: by 2002:a0c:d6c2:: with SMTP id l2mr12670987qvi.97.1549563467644;
        Thu, 07 Feb 2019 10:17:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYrsFrAAYjFJz2W+JXbqdRsYcp9WJEEV5PFAfQwIMaJaQHVoNJ4GvGf4zhceeOyLF5ZYIba
X-Received: by 2002:a0c:d6c2:: with SMTP id l2mr12670948qvi.97.1549563466926;
        Thu, 07 Feb 2019 10:17:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549563466; cv=none;
        d=google.com; s=arc-20160816;
        b=SMITXvEj4rk0fT507wRf30GO/3HnorZE1j/JMmzci9H76+uwYvClpQCFU/HTkJkVZo
         uKFChBUq4m0BVt1qzmMltlDaflWSmMg/KB5dCjxCDREzPbj5qQ7UA6VNwQIKmzOygDW4
         U7HAqC9kS/UdWNYF5ySStpGhFCBFOuZDVyH5uQJNtEyZh0UPgyMJ35mR3oGPvwe641I9
         lbqNtalygrbeeMgb5djwa0L/VBL0M2u27Zw/dsfPj9PG1qoDEmaMn2L6ouQeAGb3yGmB
         zVVJaZ9G6tjXJER4WxflZaFefJpB4Z6pyOs+nOuRWWJL09QB4piJ+XiYask3p17/yH5W
         hGmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=DxakVmrk+rxFQSFA39vWF6fSPdcTuwBUfQ7c7/5uFy0=;
        b=CyUYODRJ7qUKDni5Ro4fZi42dCubpQBqLNfSb7HDfViLQtoLNYW7krUHTn/rDr3DYt
         AnnWrW1MbWBpukPSdKv0NfyfolyDPfNi4Y/LXtOMihAwNB/G9lU8l2f7dYOeFbs6ky6Z
         vjQA7VwzlifIvnAOoq5818yrE84+X2yNMci7ehuZmSVFXHp0u0bkCHceu4gc/fcGv5Lj
         KMTfiUsTrI4kxbhTSGlBaxDbKYhVt3DNHpET2QMHN82ISO20laSvBoiVi7PAqCf8SrM6
         FEg5muh6sCyB+oviChjdcrGJd0rWULPtSoxBzLkL04zIKBNGK7YZ/ygDNbZ36MFhdr2O
         N1Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b="B47/aMZw";
       spf=pass (google.com: domain of 01000168c92e1220-36386b5d-66f7-4ba5-ba0e-d314b1d26cf8-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=01000168c92e1220-36386b5d-66f7-4ba5-ba0e-d314b1d26cf8-000000@amazonses.com
Received: from a9-31.smtp-out.amazonses.com (a9-31.smtp-out.amazonses.com. [54.240.9.31])
        by mx.google.com with ESMTPS id g124si2784515qkc.76.2019.02.07.10.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Feb 2019 10:17:46 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168c92e1220-36386b5d-66f7-4ba5-ba0e-d314b1d26cf8-000000@amazonses.com designates 54.240.9.31 as permitted sender) client-ip=54.240.9.31;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b="B47/aMZw";
       spf=pass (google.com: domain of 01000168c92e1220-36386b5d-66f7-4ba5-ba0e-d314b1d26cf8-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=01000168c92e1220-36386b5d-66f7-4ba5-ba0e-d314b1d26cf8-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549563466;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=0VffAsrUHZUiZ63MsIfnIIlVBW7/RgvsuDezdKupRM8=;
	b=B47/aMZwpGCuvge66yAeFJ1YIM+i7xuALx1AU+6y+BctQkRsA7s32uTkotT6ixxR
	vRbR+yOqW3PfCcHyIw/t1tgS5858WaLW0Xvd8Cy13zvdjhKQdEvTXRV4aC+QXAUOURh
	MjDzJiPT3clgimtKm27lFmPphToHGq2F8d0JBoLA=
Date: Thu, 7 Feb 2019 18:17:46 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Ira Weiny <ira.weiny@intel.com>
cc: Doug Ledford <dledford@redhat.com>, 
    Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, 
    Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org, 
    linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, 
    Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <20190207173504.GD29531@iweiny-DESK2.sc.intel.com>
Message-ID: <01000168c92e1220-36386b5d-66f7-4ba5-ba0e-d314b1d26cf8-000000@email.amazonses.com>
References: <20190206173114.GB12227@ziepe.ca> <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com> <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com> <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca> <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com> <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com> <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com> <20190207173504.GD29531@iweiny-DESK2.sc.intel.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.07-54.240.9.31
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Feb 2019, Ira Weiny wrote:

> On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> > One approach that may be a clean way to solve this:
> >
> > 1. Long term GUP usage requires the virtual mapping to the pages be fixed
> >    for the duration of the GUP Map. There never has been a way to break
> >    the pinnning and thus this needs to be preserved.
>
> How does this fit in with the changes John is making?
>
> >
> > 2. Page Cache Long term pins are not allowed since regular filesystems
> >    depend on COW and other tricks which are incompatible with a long term
> >    pin.
>
> Unless the hardware supports ODP or equivalent functionality.  Right?

Ok we could make an exception there. But that is not required as a first
step and only some hardware would support it.

> > 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
> >    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
> >    on the longterm pinned range until the long term pin is removed.
> >    Hardware may do its job (like for persistent memory) but no data
> >    consistency on the NVDIMM medium is guaranteed until the long term pin
> >    is removed  and the filesystems regains control over the area.
>
> I believe Dan attempted something like this and it became pretty difficult.

What is difficult about leaving things alone that are pinned? We already
have to do that currently because the refcount is elevated.

