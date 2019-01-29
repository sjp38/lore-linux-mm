Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7DC6C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:44:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B5DC20989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="KZ49LH+j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B5DC20989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41EA18E0003; Tue, 29 Jan 2019 14:44:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CDC58E0001; Tue, 29 Jan 2019 14:44:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E76F8E0003; Tue, 29 Jan 2019 14:44:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E33DD8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:44:29 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v12so14965731plp.16
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:44:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CFj7Pa5g2DeCYTbq6ol+Q6V8iNt1uylJ9ZpQIyhLCfM=;
        b=NUH3+FpeGpQTaZzIPqBMUlGmTsdqSn9RQ1mdk7Nal+QVmEpON/DCUT73MPC8Q0FyHJ
         iFp55Xfqpj7joYv9z+psSETI5x/I8vFP8PxRUircSUGiQqo4LO77Yy7/++btCzBuot6L
         8wgx5geWAXVuISkCzsTkBdJnolEoAfquWyxsKNjT7l5MxdU4Nn+/u2VM8CrqU0GEjvTO
         JkUpD1vJoNjypKyB1GYDolQF1PXi5c7VcabLeJEHfdXAJ6xPcDFZx77gA8DHvWAJbrEU
         x6AMxCh/w6vtrDxLTCw5pdEHU/P3Idgfwl3XmqXr2xRN3Dqc2f4NFE+Xi686f2NQnQxW
         MpGA==
X-Gm-Message-State: AJcUukc3A/Ie6Q5kiNokrLU4o8Rpev4aP9T/O+AKRoGvFS2oxpi37jgH
	o50QKLidwayUYQFFCmsr9npbcJ9Ny9nskurXvAMjIT3Mey9aU8DXeHu8bXvoQolxyRyyXJZtJad
	wBBUc939ifFcK5LigWrXUwISpfcrN90T/s5Fc9+XBZm44NLbsJ0kiN+wAfft5Ve4=
X-Received: by 2002:a63:6782:: with SMTP id b124mr25207994pgc.151.1548791069540;
        Tue, 29 Jan 2019 11:44:29 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7MWwqf001BLMwQNhm4x6tlHLXXg4yRSCJmdTA7UvcxZ5T81wfTGmJButb3PjckoRUL4KOM
X-Received: by 2002:a63:6782:: with SMTP id b124mr25207962pgc.151.1548791068902;
        Tue, 29 Jan 2019 11:44:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791068; cv=none;
        d=google.com; s=arc-20160816;
        b=NMil0kKtQJ3miUnKEZ97hkG73RBIA2yozxyI0Fa5HqLpUSkf9JzZTqLnfL6giObsyH
         Qo1nSti9OLM6JJPsDSNKzY7uzwstGId3JZ0ZsAOB4uVV048wtp6GN95GAwdx1xpsD33Z
         fuWVM5bsKNpL2eaBX+e1fN5RVlZIX8O4CDWShiR5nkxH4HkFCzmZ7zjwtDhNy8CVIYoX
         hOTxJBWwNZDGHlwoAL8zg09PD01/1amIXpUbYjPiJ0xvPBNjBHN7g1q688ymBuSXP0mh
         eDknCzcvNhskKa4DNkq3QhdwQ8uU4vrlfNCq3haf6zN8l2W6psDfGghDj6fZahdEkPp3
         vIGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CFj7Pa5g2DeCYTbq6ol+Q6V8iNt1uylJ9ZpQIyhLCfM=;
        b=TxkPbgxp8OIig4WE4FHvHOMyaeFrU1JlBp3KT8HE1JU/IJJ3/3innrp0uRYc6/BLQJ
         HD+WejGSHkc7cCMtd8Nh0iVI1PGzjOUnBQUCClcIgrsCV8vYbtDWsK/66h6hFr/QWk1H
         hx9pyqRB07XGzj5WiWPBjaqVo/4u5vzDXCLuSZJNyp5c+LF96cpaP9vhLMBMLhYxYGHB
         oybSZih52PBA1fBheGk5dAqrEjRP0vIX1RvD3sP6VFLVTBB1D4ScpxjVJ9zFR2vAo0Vd
         C+Ff0i5xkdkqcdlQ0mb4x1RcEwsxOHoe42+Eibo+yfIhf4zEI7xVRbgClydGYiq4KWCK
         XLiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KZ49LH+j;
       spf=pass (google.com: domain of srs0=yq8b=qf=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Yq8B=QF=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e13si35185625pfi.271.2019.01.29.11.44.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:44:28 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=yq8b=qf=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KZ49LH+j;
       spf=pass (google.com: domain of srs0=yq8b=qf=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Yq8B=QF=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1840F20882;
	Tue, 29 Jan 2019 19:44:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548791068;
	bh=viEJwDEtg1GHjzjkuyc+bBKWHo390MegK+/fo4Fble8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=KZ49LH+jLUB5srps9pOXePp/VyVK991R5wyjKZybFUFX8MoQbeRfWiIJ2VIgtJ0ON
	 BIFTzisFgCYTDNpFD+PiiDclPm8bLV+kxGugwnruf/jhxkgGGOSQHLA6pLyhwHnCkM
	 j3wL4ZpMUUn9yw+WfZbhWycVuoC0YG+hjkARojvo=
Date: Tue, 29 Jan 2019 20:44:26 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
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
Message-ID: <20190129194426.GB32069@kroah.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-2-jglisse@redhat.com>
 <f66ba584-9c4a-f6cd-c647-9b32a93be807@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f66ba584-9c4a-f6cd-c647-9b32a93be807@deltatee.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 11:24:09AM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
> > +bool pci_test_p2p(struct device *devA, struct device *devB)
> > +{
> > +	struct pci_dev *pciA, *pciB;
> > +	bool ret;
> > +	int tmp;
> > +
> > +	/*
> > +	 * For now we only support PCIE peer to peer but other inter-connect
> > +	 * can be added.
> > +	 */
> > +	pciA = find_parent_pci_dev(devA);
> > +	pciB = find_parent_pci_dev(devB);
> > +	if (pciA == NULL || pciB == NULL) {
> > +		ret = false;
> > +		goto out;
> > +	}
> > +
> > +	tmp = upstream_bridge_distance(pciA, pciB, NULL);
> > +	ret = tmp < 0 ? false : true;
> > +
> > +out:
> > +	pci_dev_put(pciB);
> > +	pci_dev_put(pciA);
> > +	return false;
> > +}
> > +EXPORT_SYMBOL_GPL(pci_test_p2p);
> 
> This function only ever returns false....

I guess it was nevr actually tested :(

I feel really worried about passing random 'struct device' pointers into
the PCI layer.  Are we _sure_ it can handle this properly?

thanks,

greg k-h

