Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 733EEC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:53:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32E4E2080F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:53:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32E4E2080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDCD38E0003; Tue, 29 Jan 2019 14:53:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8B118E0002; Tue, 29 Jan 2019 14:53:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA2808E0003; Tue, 29 Jan 2019 14:53:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC2F8E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:53:08 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id u32so26212975qte.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:53:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=75hsV7Pqqt0+N491/wcw4j7zb4wvemt5Snw3rZEGqXY=;
        b=BAoCMeto0xRcSmGtOdOJ2HEJ3QDajiCKCsNjSJo6lKs7taisL9b4Yjf1m8QEIbRzoZ
         7u6CqsyyGl1K03UjxV2Cj39IxWVBFhqhmfBjQKnTd1t7eJ6FJm6UURQoaBIZT4Lj0cMn
         F6rIjA2sQEeRcJe8Ym1jZDrQxlkBUKVfIyaMAbgh7Z9YmIRqlTJREurkNyrzac/2TY7E
         6TGM2zOhui7pnJ/Wss4DK9kbs0oa+UKfmvgHqjcQ0hPKA2J6cUX2Z2QvPlKA0uY5Izwq
         CrCWNaOjca8p4iYzEyhFKz0Sb+ESKiQVSEF8jOWh7/HVvF23sWh7ZDf1z2zJkdOOhvvf
         h4Gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeBA1D2+eeYqcBDkyf2ebS0Az/t90+r0vn9yd8VrMQyNQ4iHLUW
	5lJJTFvKFeADmNudkopIAC0EAXJ4UPNAPXPPVw5MjdoAH9I/aRVgseBGNxptj4+8vvMjw7IxtqE
	3fmKPQ1Rjj/4zAkctOIwTFAnkLQJBjYkgqGUlpibyPpo4GN96nsJQOubCj1Uzelc70Q==
X-Received: by 2002:ac8:4a10:: with SMTP id x16mr28252094qtq.164.1548791588431;
        Tue, 29 Jan 2019 11:53:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7dWmX7Y6aQRr53W71I5T92KsLo1jLSCtbbx+SgkArsX2I0CfwafRWPVmFCMu6tepAp3+4D
X-Received: by 2002:ac8:4a10:: with SMTP id x16mr28252075qtq.164.1548791587969;
        Tue, 29 Jan 2019 11:53:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791587; cv=none;
        d=google.com; s=arc-20160816;
        b=SLCy/TjlazHMTwSxeil0+iDZwUuHl/h6bvZgVOXLKOV0XQPMpwia6neoW94nwKaIht
         fC65eE3d5HR9RO4vsTQt4rW4VMzLTWD5EXkS6UJyQSDN/FGF8rpB8K3xTW/NZf90oxHL
         G7OnLlGHTx7YW+e0EuqygdEV7UEdl8cCIu1z1dubgxJsZVYb+UvOBCWCSSI6znk4bYiV
         hb4WqiN3+0L7YT3ADYtynFlOuqvg3EsL9U3/ghpBsAhRt92vuGIjZ7DC4exe5PNY15Ep
         yvBZGcXgqX5JCbF4yo95Lna7diB5AZHSYVo0Bx208VE9//beE2N7WvqdSykt4mE1gZiC
         gu1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=75hsV7Pqqt0+N491/wcw4j7zb4wvemt5Snw3rZEGqXY=;
        b=tQaIGLM5XJ4OcUydECwa7GYTugvKCdFQCyE85Kq4OfcbcOGX8w6MznAWtADbLz17U5
         SXU2P+j2cpnUNcIQps5/snGynKaE/P9hIibKxt9yTKU9njSvCm3lhIVMafeoiCsDDwgM
         zlSXkzuIw5t26XJGzND38wDzjfsoVlFRA+wfXNt/JeSlA71tKs9uhD3DSzDCkJ+WbUmM
         ZrXT2cZ9OFQTVr7xvcLXF9RJE+qkZndm97BjF8kogX+z2BuQkGo2RTOpoMYGSRaiwR7l
         Likxp5Yc5DFys1AHFnTv8EALmgjCtd5Z93TE+0hf0Zb1SszGp7Npae6iFXlkQ0H7O0OE
         mfSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t65si1759018qkh.219.2019.01.29.11.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:53:07 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CF0B97AE8B;
	Tue, 29 Jan 2019 19:53:06 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E322419745;
	Tue, 29 Jan 2019 19:53:04 +0000 (UTC)
Date: Tue, 29 Jan 2019 14:53:02 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>, linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	iommu@lists.linux-foundation.org
Subject: Re: [RFC PATCH 1/5] pci/p2p: add a function to test peer to peer
 capability
Message-ID: <20190129195302.GI3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-2-jglisse@redhat.com>
 <f66ba584-9c4a-f6cd-c647-9b32a93be807@deltatee.com>
 <20190129194426.GB32069@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190129194426.GB32069@kroah.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 29 Jan 2019 19:53:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 08:44:26PM +0100, Greg Kroah-Hartman wrote:
> On Tue, Jan 29, 2019 at 11:24:09AM -0700, Logan Gunthorpe wrote:
> > 
> > 
> > On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
> > > +bool pci_test_p2p(struct device *devA, struct device *devB)
> > > +{
> > > +	struct pci_dev *pciA, *pciB;
> > > +	bool ret;
> > > +	int tmp;
> > > +
> > > +	/*
> > > +	 * For now we only support PCIE peer to peer but other inter-connect
> > > +	 * can be added.
> > > +	 */
> > > +	pciA = find_parent_pci_dev(devA);
> > > +	pciB = find_parent_pci_dev(devB);
> > > +	if (pciA == NULL || pciB == NULL) {
> > > +		ret = false;
> > > +		goto out;
> > > +	}
> > > +
> > > +	tmp = upstream_bridge_distance(pciA, pciB, NULL);
> > > +	ret = tmp < 0 ? false : true;
> > > +
> > > +out:
> > > +	pci_dev_put(pciB);
> > > +	pci_dev_put(pciA);
> > > +	return false;
> > > +}
> > > +EXPORT_SYMBOL_GPL(pci_test_p2p);
> > 
> > This function only ever returns false....
> 
> I guess it was nevr actually tested :(
> 
> I feel really worried about passing random 'struct device' pointers into
> the PCI layer.  Are we _sure_ it can handle this properly?
> 

Oh yes i fixed it on the test rig and forgot to patch
my local git tree. My bad.

Cheers,
Jérôme

