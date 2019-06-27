Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFFD1C48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:53:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70B622133F
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:53:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70B622133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD2E96B0003; Thu, 27 Jun 2019 12:53:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D84048E0003; Thu, 27 Jun 2019 12:53:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C71CE8E0002; Thu, 27 Jun 2019 12:53:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF306B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 12:53:52 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id f189so892076wme.5
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:53:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xU/whg26sgUfF+Dq0O8Uj10RgLXDjiGOor0v0A6Ejxg=;
        b=i/e6DVL4vRVo8g3LTEAsYL0JZz4Eid5F2li1j4NW7QohY+haVcAv+Uz8MZIdUIUsCO
         dXhrxp2BueEfzg0NS8eipCHn3DPHy4C++I1m6yxKRO2QNl2uS469FqLwDCu9Ji2BaqPS
         E2b+TLNN7lAirHWuJYUOjTtf2oGYaOHK11bS+9/OtOgTC5n4/h+Mp6/wK2WB0+s6k3Ba
         hG2cRKuxtGcb9xqwpUETDSaQqNDvUF1WFDtKslcOZvy77XfpKJBwE7oDguizDRln3/qu
         w2QLOkfGxsqyqJE8XzmCSEeBeIKmVGyhGeiRWjpCxddc4zNFAqvM4gA4Cnvxf2q2igpm
         FmiQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 213.95.11.210 is neither permitted nor denied by best guess record for domain of hch@lst.de) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXdp6dBVZTS0UtIwsaz1+JGD1gla8y3zUq0YLin8jmSUWaHg9YY
	6U+HBhGUHfqkljxnDBF2JrA5v6/HUu/FD4aNyz5dRftdlGT/i5MQGx7Z6QLCTBZh2QUO9XDCW7W
	Bo6Kn5imnX2hhF71YFRIcf4XjzOVG2ayq6jAoyMZtgsU/g7MKZ1uZVj0SgPZipZc=
X-Received: by 2002:a7b:c202:: with SMTP id x2mr3684289wmi.49.1561654432089;
        Thu, 27 Jun 2019 09:53:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhMq5CIupk5EC2lECby9Guaz6cVOApAD7y2Is6IHUdnBbfngBomRyxjEu+L+EUVGsNA0SZ
X-Received: by 2002:a7b:c202:: with SMTP id x2mr3684254wmi.49.1561654431439;
        Thu, 27 Jun 2019 09:53:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561654431; cv=none;
        d=google.com; s=arc-20160816;
        b=0YS/7NH8P0IRKlLRgAdcFK7oFfqnOsgTZCJVDgIJI4ycItBZ/+LYUM7yUxgEcUXY0K
         lGencDGcQ18rDiMH1UmIyEkLIeRW3exJGIKIsnfsbDTEQTqay6qUH+hp73bx8QZs68vj
         KUCJqp71MRRDY1CJBC8V72rhms0S1G3gD6kUmguUDDsmttPAxA98Xhsp1d7CtGnwmx5+
         KpoWfmm7DcS7/KYkS/UWxbrDCqcDBxJTe3Ktdq8BQ/ZlyxK9EspKWiJhHJ2AcYIggZWw
         XO8iSg9v98rbI9UaZNlB01a554ukiEkeBA3LGxpEAGb0wFuSR6n/4PU74RSt9SjWur2r
         3dow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xU/whg26sgUfF+Dq0O8Uj10RgLXDjiGOor0v0A6Ejxg=;
        b=IRAPnG0JbVImndRbd9qNVYgi/3PZra/sPxyvOVREcsaQp25BHMfo3D47G2urmpJwoc
         tXQfGcPC0PgFXzEIU7HU8Seu3lbJfYYvTerFu464cTZvzNvHeSvY8rMs9kzcU0MPcywB
         QyPsXMOhYS+WdrQ1BMrryFuFowWcp7BqdkpD9K8gbhOQI4TBJnGdslqihiheQpHjiF4q
         eM7jhFwL4VGRhy3KzPc/1insl15zbkuUn0R+BT02frKNW85ujcPqjicCTDZaBUFSARl8
         cAL6hfVFIjFxezXV0YOPP8obd9328UPTPavPEYcm876/w44rNR/rXgcmc6CycqD/F8aa
         32JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 213.95.11.210 is neither permitted nor denied by best guess record for domain of hch@lst.de) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de ([213.95.11.210])
        by mx.google.com with ESMTPS id b3si116265wmd.52.2019.06.27.09.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 09:53:51 -0700 (PDT)
Received-SPF: neutral (google.com: 213.95.11.210 is neither permitted nor denied by best guess record for domain of hch@lst.de) client-ip=213.95.11.210;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 213.95.11.210 is neither permitted nor denied by best guess record for domain of hch@lst.de) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 4B57968C4E; Thu, 27 Jun 2019 18:53:49 +0200 (CEST)
Date: Thu, 27 Jun 2019 18:53:49 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: Re: [PATCH 12/25] memremap: add a migrate_to_ram method to struct
 dev_pagemap_ops
Message-ID: <20190627165349.GB10652@lst.de>
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-13-hch@lst.de> <20190627162439.GD9499@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190627162439.GD9499@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 04:29:45PM +0000, Jason Gunthorpe wrote:
> I'ver heard there are some other use models for fault() here beyond
> migrate to ram, but we can rename it if we ever see them.

Well, it absolutely needs to migrate to some piece of addressable
and coherent memory, so ram might be a nice shortcut for that.

> > +static vm_fault_t hmm_devmem_migrate_to_ram(struct vm_fault *vmf)
> >  {
> > -	struct hmm_devmem *devmem = page->pgmap->data;
> > +	struct hmm_devmem *devmem = vmf->page->pgmap->data;
> >  
> > -	return devmem->ops->fault(devmem, vma, addr, page, flags, pmdp);
> > +	return devmem->ops->fault(devmem, vmf->vma, vmf->address, vmf->page,
> > +			vmf->flags, vmf->pmd);
> >  }
> 
> Next cycle we should probably rename this fault to migrate_to_ram as
> well and pass in the vmf..

That ->fault op goes away entirely in one of the next patches in the
series.

