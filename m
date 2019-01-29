Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3804FC282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:56:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDD2F2084C
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:56:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDD2F2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A80458E0007; Tue, 29 Jan 2019 14:56:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2DA08E0002; Tue, 29 Jan 2019 14:56:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F5D18E0007; Tue, 29 Jan 2019 14:56:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63C208E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:56:58 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z11so23076762qkf.19
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:56:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ZzB2//56DOjYDqpsMcUi6sQ0CFC8hIxqArgHRj7qkRw=;
        b=OBQVlwuQbnx6JIq2C2QgFKKDXX0RpsKbgkpcwbqyS8c51OlDRxPQR13jeBhda2P9dZ
         hXkiFaMiGmIbqiJcAf02ZCePuUFlPoNfhIDofrz2oHz75VOdimhqkg2LeKChqsE+YkTe
         u7kktUapchk0AKRy0qs2NkgSUgMshMUG/tNBkhKaDQFF+VsIbMCEYhzMf2gLiokyRY+t
         hG23iph410rJwqHHrP1D+1t16rrP9snPo7PS+vQP8merukAwJh8tvQ+XwQcdzWgSsQqC
         BtFKaH7fGIGrJSPwNuEFefInLNSG9Z8Jv4+3EevNik1/HxPEBJee60uLfPoJ8DKRvF4q
         VOJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukc758H4nnqQPNmw/8QQClLiWmkezg2vGaG/+DUMg0vUyAzrYD1b
	uT65Ot9+R9GGTsBLpyxUMQrodn7c085X+OJzNMHZ+eK7UJzp0GVmNBx2yZiYs+uOWMdQOsu2BNk
	4ru9lPo1udfN4jR6Oy+Qu3NPjc11sIINjVYGCYf6hLVrOP8MH8aXcr6h1kMwvKNu0qQ==
X-Received: by 2002:a37:9bc3:: with SMTP id d186mr24539573qke.22.1548791818159;
        Tue, 29 Jan 2019 11:56:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5FAe+fM597ZodBzWEHv6mQd97tH0CZlbbq7s+MErSV7Ah94iv2W2DJP1fwdkBLeOeGTWuL
X-Received: by 2002:a37:9bc3:: with SMTP id d186mr24539544qke.22.1548791817708;
        Tue, 29 Jan 2019 11:56:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791817; cv=none;
        d=google.com; s=arc-20160816;
        b=a5cokupzseOu/i7QGmo0uyR2Ph64VhE2sYFqaDlrqiO6lNhX4tDnt5uSwr0SwqhS19
         iRmArcdzeWxjs11Reqc0Wh5pWvNmI3CdUqR3+kcY84HiSQ4tHNlXVroWJdnsJx5Myfei
         HAbnVF/Gywh/8gu/djPp/VxxangW95uw7uDbPdJS4+lcMPTyJY1Si7KvYd9z6oemtZNX
         VbFWcbKjQXfUu6SX5UbIVei5LusVTgIc/Y8ZSKMa9wsGv3gS3prf1di6DIdLwyTddzPO
         aWPufCIIGTT/bqwTTORLN8XA4zBBZCsTB5zhmucEDBs+zFAKoM11Zcckx/xM5koVt+rp
         TMww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ZzB2//56DOjYDqpsMcUi6sQ0CFC8hIxqArgHRj7qkRw=;
        b=bPNxaiI7Da6/JZCesHOMmmfXUVxPaB6yLt0t7FQU8ds3pFt4R93M3yc1Eo/VP5fJ5G
         boBneFWTsgidmT0QNkdqlQaettLkjQ4nV3f4WUd5Df+AlxdOejxmwY68oNQ86HwS39Cw
         UDeLl6bGmAIY30cwG3UuDGrkEGAHgUMpu7TvVimLHYqiDO7V8zEZ7x3be02DJ09XQxTy
         R/efNWSV+JXM/3efrR3+qoTMW5QvNpFxsIC/xiR57r+Qg88RRVout6tRbVMHn81TD0et
         oeJrCezXsBisUVd3jVj0f7TDimw8u3i3Fs4qTT4qKzh4Lf2tVs/8nI0DoKf9R4uKn9m2
         vB9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o61si2171046qte.74.2019.01.29.11.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:56:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5E41A2DD2A;
	Tue, 29 Jan 2019 19:56:56 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EE021600CC;
	Tue, 29 Jan 2019 19:56:53 +0000 (UTC)
Date: Tue, 29 Jan 2019 14:56:52 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
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
Message-ID: <20190129195651.GK3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-3-jglisse@redhat.com>
 <20190129194605.GC32069@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190129194605.GC32069@kroah.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 29 Jan 2019 19:56:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 08:46:05PM +0100, Greg Kroah-Hartman wrote:
> On Tue, Jan 29, 2019 at 12:47:25PM -0500, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > device_test_p2p() return true if two devices can peer to peer to
> > each other. We add a generic function as different inter-connect
> > can support peer to peer and we want to genericaly test this no
> > matter what the inter-connect might be. However this version only
> > support PCIE for now.
> 
> There is no defintion of "peer to peer" in the driver/device model, so
> why should this be in the driver core at all?
> 
> Especially as you only do this for PCI, why not just keep it in the PCI
> layer, that way you _know_ you are dealing with the right pointer types
> and there is no need to mess around with the driver core at all.

Ok i will drop the core device change. I wanted to allow other non
PCI to join latter on (ie allow PCI device to export to non PCI device)
but if that ever happen then we can update pci exporter at the same
time we introduce non pci importer.

Cheers,
Jérôme

