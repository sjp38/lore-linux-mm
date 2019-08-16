Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5DABC3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:28:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 855A82086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:28:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Ixj/SoRJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 855A82086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 039866B0006; Fri, 16 Aug 2019 13:28:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2B506B0007; Fri, 16 Aug 2019 13:28:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1A796B0008; Fri, 16 Aug 2019 13:28:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id BF9BE6B0006
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 13:28:48 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5EF1F181AC9C6
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:28:48 +0000 (UTC)
X-FDA: 75828975936.20.tiger97_4cd846a5da609
X-HE-Tag: tiger97_4cd846a5da609
X-Filterd-Recvd-Size: 5114
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:28:47 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id s14so5398672qkm.4
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:28:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=F45QDEu01tuosMxeBXshNdQV0qdzUW+A54VgIcKeIPQ=;
        b=Ixj/SoRJ+JjSkgtbnuAlNvEeswSUCwNKuaFLHbk074FCSMAJ0pzN8tT5ReRltjL3Gf
         RXaC7Ipl87f6oMqTWoY3dK/rv/Ebn3jzmPoC+B9dSW991uhIw2U1xamLQQ3fvpz00edL
         a1Qocl++KZdMEzFneehLs3O2p4g22HJREvBTuudS9ss8+VoG+YpK0ZFVhPwXCQgOxb6j
         l6IQtFd6edwrjdoeNrOu2K5jjVrdqOXCbrbFGIwZVckM7s7BYM9XDbDzPSyLrnPtV7PI
         DEyvAFgALyQTa6Ip+Z3b1PmCilg+vCouLsoy7GiMDwRlevDCUcK2g+VvO1oDcMgFgFEI
         aK0A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=F45QDEu01tuosMxeBXshNdQV0qdzUW+A54VgIcKeIPQ=;
        b=feChvtD7KBI8I6PLNmIvTiTaj9d4TKrf9GZ3SF6AH9ksSe8TkG2ojMMtQ5pJdBKQli
         yo2ewDofL3TkBOGDXtOBv8oDBxTTIVof4qTohonyjXAhWxw/gEXz/VQ6ofyon/ztXQK5
         AUXx+B+OjOiW4LfpeLlUH9rMr+UlsSahkOBV0dYnlebQD3PRvafWw6bYW+ikxB6Wwfwb
         G/3MevfmGAxe5leSvIYMYrHBpIciOONuWrIJ7FSwHZ73sZigKDS3Pg9Nv1qmg3aaq92h
         Hk59yvwa8aD04oC7dBLfiNm08OgwkcBJ071QePHT3dwZQr/daFKR0I2hqE3i8NrHs2oW
         wb9g==
X-Gm-Message-State: APjAAAWsZBRFqpz5x5OqbIkJ8SJsUD3uH0lNlY2RDkjFUMI6PBmQI7uj
	RaKMGphJCP/efSsxBSpVG87qqQ==
X-Google-Smtp-Source: APXvYqz4MWjmBxvJTbbDEud8Nxfi8cYWfH0bH7syzSPmrbjXevX053Df4aHxdDIIl0mAsdz2AlYJ2Q==
X-Received: by 2002:a05:620a:143b:: with SMTP id k27mr9740698qkj.426.1565976527486;
        Fri, 16 Aug 2019 10:28:47 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id t26sm3867534qtc.95.2019.08.16.10.28.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Aug 2019 10:28:47 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyg1u-0000vn-Jo; Fri, 16 Aug 2019 14:28:46 -0300
Date: Fri, 16 Aug 2019 14:28:46 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
Message-ID: <20190816172846.GJ5398@ziepe.ca>
References: <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
 <20190815194339.GC9253@redhat.com>
 <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
 <20190815203306.GB25517@redhat.com>
 <20190815204128.GI22970@mellanox.com>
 <CAPcyv4j_Mxbw+T+yXTMdkrMoS_uxg+TXXgTM_EPBJ8XfXKxytA@mail.gmail.com>
 <20190816004053.GB9929@mellanox.com>
 <CAPcyv4gMPVmY59aQAT64jQf9qXrACKOuV=DfVs4sNySCXJhkdA@mail.gmail.com>
 <20190816122414.GC5412@mellanox.com>
 <CAPcyv4jgHF05gdRoOFZORqeOBE9Z7PhagsSD+LVnjH2dc3mrFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jgHF05gdRoOFZORqeOBE9Z7PhagsSD+LVnjH2dc3mrFg@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 10:21:41AM -0700, Dan Williams wrote:

> > We can do a get_dev_pagemap inside the page_walk and touch the pgmap,
> > or we can do the 'device mutex && retry' pattern and touch the pgmap
> > in the driver, under that lock.
> >
> > However in all cases the current get_dev_pagemap()'s in the page walk
> > are not necessary, and we can delete them.
> 
> Yes, as long as 'struct page' instances resulting from that lookup are
> not passed outside of that lock.

Indeed.

Also, I was reflecting over lunch that the hmm_range_fault should only
return DEVICE_PRIVATE pages for the caller's device (see other thread
with HCH), and in this case, the caller should also be responsible to
ensure that the driver is not calling hmm_range_fault at the same time
it is deleting it's own DEVICE_PRIVATE mapping - ie by fencing its
page fault handler.

This does not apply to PCI_P2PDMA, but, lets see how that looks when
we get there.

So the whole thing seems pretty safe.

Jason

