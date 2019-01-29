Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0690FC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:46:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA81B20989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:46:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vSEbdOMd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA81B20989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B6748E0002; Tue, 29 Jan 2019 14:46:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63D5D8E0001; Tue, 29 Jan 2019 14:46:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E0218E0002; Tue, 29 Jan 2019 14:46:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 062EC8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:46:10 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q63so17696616pfi.19
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:46:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Ui762Nf9phWqllFBpP0gszm+0eeFE6+RSm8nk87NWu8=;
        b=hrQrOC/x+Evjry3MhR9aT2qthV63aG9guGIptGIxRvWa1e/lL3jAWPfoNSF7lf/izr
         SQDOd1vqMO6rfEb8x+2pi6odg/MDQaWJHbHxYE8VdIgw0IFmxOPDCM1OfEd4pczhEGI3
         4EVsGTIfPpRpMrt9yMdeqpCWnF7Z1h9zY/3yqmGEsyb1oRVyrSuh+CB5wUaUiiT44YyW
         PL0Tehuq76/77Sca4dFjlu5cNSEHlMhHlLMZYz/fsmrAYsiM71T4VAlelMXICFyZUxTK
         DwBTuELFjSgNCl9Mpxnzks113b09nW9cyLV6YN8Q5+3aj8NyV6pn4FofabWaeR4KhC+F
         TeGA==
X-Gm-Message-State: AJcUukf8nl8xB7Etk56+LtP6DPz+Hp7NTDfz+sVG5j8taipvVXsCZoj1
	qe/p3ugoyuq+ovB5Hxc0pJ9+Nlfah67UyiS9yUZdiIn8IPShAw+ddQ6bntA11ZWdSHErWfJgvLB
	55UG1Woz1Ul3KlTBbk0VlDX1Rhl1S80mVDPNGqnckNWN6NKh9afwZ4781QxgPgN4=
X-Received: by 2002:a17:902:2dc3:: with SMTP id p61mr26878847plb.166.1548791169720;
        Tue, 29 Jan 2019 11:46:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4UELe5Pjm8F+JcAJxO0h38wVOaz1ZCFmbhnpnv457nL/YKke2KnsAge1DM0QERwMe3Oms3
X-Received: by 2002:a17:902:2dc3:: with SMTP id p61mr26878823plb.166.1548791169177;
        Tue, 29 Jan 2019 11:46:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791169; cv=none;
        d=google.com; s=arc-20160816;
        b=Jiy3gCkGZ7uyLw80yGlyS4V8LbNDtIdi9QMQdRYgxYyqlfDfhHCXQu5rKAaBQeLc4D
         UpI/wVcdRk9ARXL4/141Fx+eVIDeAG4EVbUklc3DrHMDRG3cXUjGpEMcQQ6o8vydQyoc
         ByMvD1UVnefp7X3nssuAnm0RjSc66loLiLOXxUqjjPAx1osuBFckkDR6hZvrx4q0RCcf
         klPqPQB87BB2HWeZkVpp6Smp7vkzbgdemQ8VupTocPEGRhpbV8zC3FVSYsNrxOo/0r3q
         O+z+zho/yEAePLjEOhc21siVte4gaY/n0vOUPML6LA/Dg0424NieSwaMwSWjz7xm4T4s
         s1XA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=Ui762Nf9phWqllFBpP0gszm+0eeFE6+RSm8nk87NWu8=;
        b=xiq1Jt/mK9sAUGAaVUnoxxrXvWcIsa0P5oRoSFw43HfzXy6sWKcrVtFci5h/dRExw2
         tLX4/bUYKByJsNAykQ83P2mudDICmDOug48yaRnguTSthJXF1uziTu763EZ+EWz7+qrl
         ej1mCiFU6hS51B0jlQhCXRnqpaYTH6c+v3itMexx5XYBk7v+5RsCYzEC30vT3shSCyxE
         T0x7RFGPclXtFTA8aZnVSjXvKyOVCD6f+xMxOWwnfiQS2Vs98GHXjKf21rJi4nt8j4/l
         BRKAn/9CKvsgvwTIabf0Ftei8iZJ/2s/vMvnzjGBxvYzlDwnp841axy05visBZsjcFIk
         uTVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vSEbdOMd;
       spf=pass (google.com: domain of srs0=yq8b=qf=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Yq8B=QF=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p3si5896015plk.424.2019.01.29.11.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:46:09 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=yq8b=qf=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vSEbdOMd;
       spf=pass (google.com: domain of srs0=yq8b=qf=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Yq8B=QF=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 308A320882;
	Tue, 29 Jan 2019 19:46:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548791168;
	bh=n979B516WvO1WMnU9UTm77UKXWyQQ/SZXEgeapMTWYo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=vSEbdOMdxB5zWHviLP5pUWw/pnkTofE5nbC3y6u6wmVIIjKd0uVrkqkM46iS+Zz3/
	 /oCcoZpH9rhZa64+PdpUEKsaAK3nyCg9x7phTjMPalaJVViQJOMrOZrwStIWdN6Tg/
	 hbaBioLq5FUwGZAnQ27o4GMt5X6OG52soxoLUyLg=
Date: Tue, 29 Jan 2019 20:46:05 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Logan Gunthorpe <logang@deltatee.com>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>, linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	iommu@lists.linux-foundation.org
Subject: Re: [RFC PATCH 2/5] drivers/base: add a function to test peer to
 peer capability
Message-ID: <20190129194605.GC32069@kroah.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190129174728.6430-3-jglisse@redhat.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 12:47:25PM -0500, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> device_test_p2p() return true if two devices can peer to peer to
> each other. We add a generic function as different inter-connect
> can support peer to peer and we want to genericaly test this no
> matter what the inter-connect might be. However this version only
> support PCIE for now.

There is no defintion of "peer to peer" in the driver/device model, so
why should this be in the driver core at all?

Especially as you only do this for PCI, why not just keep it in the PCI
layer, that way you _know_ you are dealing with the right pointer types
and there is no need to mess around with the driver core at all.

thanks,

greg k-h

