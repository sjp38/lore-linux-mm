Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81625C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:44:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 467992087E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:44:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 467992087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E79368E0002; Tue, 29 Jan 2019 15:44:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E27088E0001; Tue, 29 Jan 2019 15:44:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF2698E0002; Tue, 29 Jan 2019 15:44:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4F528E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:44:25 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id x2so17477075ioa.23
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:44:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=WC0nXAalSeMPrkZXj5Bmu+vvjinEgIeQJ1/CWGuDTjI=;
        b=uELtu2R9IAbYcc5ADXpHLxnnZ2u1n87m5s+Zqb6M20bIsO7yqohHzlFT+jxauutdhQ
         wmiTXXWCIY2on2aKtAMdWPGCagWj0PDmxJlpyRKTLkEnumBdHKlRQCAdt60tqpHLW+iB
         /PINh3F2AQzSz2eRuimEYaGt4yo9ve6Gonp90NpRc9JDWKjubvgP4uic3aet73aQ/WI3
         kD4NRkwWyySXJ6W10oLFKmD2VsocpJ/LiebGdpbk2UTkRmj7bBtfVrVC8GKxjG12MVzF
         N0AHi/eC9n9sX0ooUjp9mvhp8T71tDbX7I3fp0oFEGTZ5xDnMuxW/QaPJgdOIJa2LVVX
         E2Dg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAubOz4Go4M9vU+OGkbsndtSqgfQd4YAHCbUkNhK8O40oIXsTx0f/
	ES4IfVVXT/5tpgXakUWlNZEEpxVkdzAsHNuwIdF0TzlmWKanGk2otP5HGIOGhmciyGiKeiNu8eW
	SgI37dd1m/ewC8wonFP1NDKL92zBdIfN1rsvSY/uHafAl3YJm4mK5YN4BbbMYZBK/4g==
X-Received: by 2002:a5e:8517:: with SMTP id i23mr13646341ioj.28.1548794665447;
        Tue, 29 Jan 2019 12:44:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbQdvQei3Kg+92FUwnNKS824U/7tAPscbcqyiL2oByEqkSTBiaAzHt5JZcjuvZWLxDjg485
X-Received: by 2002:a5e:8517:: with SMTP id i23mr13646326ioj.28.1548794664892;
        Tue, 29 Jan 2019 12:44:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548794664; cv=none;
        d=google.com; s=arc-20160816;
        b=TZJjfFoV2Ph8frdOZ6TkQmatKR0/PpxMv7RPU77w5+2HGUhh0Ua0VQtOLmDWlOUKvg
         jXmBITfjeQ+kAaMFGWQv0HQ3TZ9zYRoB24nxmw1OFqV0eK4OSFV6iADQyIjHOqvgj0K2
         kOXHeypC4PjgOua85jV1lMPMraHHEVRoVPPiii8XLli0rP7oLxit60tGqfnhBwJDAR4Q
         GBWD/EJR60adTpu0mLNHTdvthHH3ojouP7qT94Ez8UK+XDkjQ2/quGPW7apaUhQtPdt6
         HZu/k/jiUw8ogSuy9S80q7EG+Huss2akjeYi8+GOR8QjpjWzgdII6m3YkzG28VbRZmEy
         Ofig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=WC0nXAalSeMPrkZXj5Bmu+vvjinEgIeQJ1/CWGuDTjI=;
        b=0REe+IC75FPCbsTm2Ely54NwZ6S1U3IlcFyUmnSahVWxaYk4NrrPPTlHgkmwtGQaF6
         ZLNHZ4IkfcmWk32MDMt4eiB8Z47gXlY8UqXNj8MJfeLoXmKDdhCLFO8vpseh2tvses/i
         3WxsgDiBhMBKrLxCuH4fPzq9vg9dKaqCZbIcloyvwSURyRzM19YbnaMgVJUmfkO4aUnl
         kBKi3GkEallEv0+t+JyiUL/KWRPUpisPJ+z2CAi7yUwYaRaDwsP0yJFKpDB9xYg4GKvH
         A1KHJjgELzUb82wp9HpgAPhQJ8zNT0QPSHGTx1rQmDvZtObi88Bhf8V/7R+vSyKu0Nzw
         /1NA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id c100si2321935itd.11.2019.01.29.12.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 12:44:24 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goaEu-0006kt-Rd; Tue, 29 Jan 2019 13:44:13 -0700
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn Helgaas
 <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>,
 linux-pci@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>,
 Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
 iommu@lists.linux-foundation.org
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-2-jglisse@redhat.com>
 <f66ba584-9c4a-f6cd-c647-9b32a93be807@deltatee.com>
 <20190129194426.GB32069@kroah.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <8b4e0157-4eaf-c79a-28d0-7a266abe2207@deltatee.com>
Date: Tue, 29 Jan 2019 13:44:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129194426.GB32069@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, hch@lst.de, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, jgg@mellanox.com, Felix.Kuehling@amd.com, christian.koenig@amd.com, bhelgaas@google.com, rafael@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, gregkh@linuxfoundation.org
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [RFC PATCH 1/5] pci/p2p: add a function to test peer to peer
 capability
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-01-29 12:44 p.m., Greg Kroah-Hartman wrote:
> On Tue, Jan 29, 2019 at 11:24:09AM -0700, Logan Gunthorpe wrote:
>>
>>
>> On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
>>> +bool pci_test_p2p(struct device *devA, struct device *devB)
>>> +{
>>> +	struct pci_dev *pciA, *pciB;
>>> +	bool ret;
>>> +	int tmp;
>>> +
>>> +	/*
>>> +	 * For now we only support PCIE peer to peer but other inter-connect
>>> +	 * can be added.
>>> +	 */
>>> +	pciA = find_parent_pci_dev(devA);
>>> +	pciB = find_parent_pci_dev(devB);
>>> +	if (pciA == NULL || pciB == NULL) {
>>> +		ret = false;
>>> +		goto out;
>>> +	}
>>> +
>>> +	tmp = upstream_bridge_distance(pciA, pciB, NULL);
>>> +	ret = tmp < 0 ? false : true;
>>> +
>>> +out:
>>> +	pci_dev_put(pciB);
>>> +	pci_dev_put(pciA);
>>> +	return false;
>>> +}
>>> +EXPORT_SYMBOL_GPL(pci_test_p2p);
>>
>> This function only ever returns false....
> 
> I guess it was nevr actually tested :(
> 
> I feel really worried about passing random 'struct device' pointers into
> the PCI layer.  Are we _sure_ it can handle this properly?

Yes, there are a couple of pci_p2pdma functions that take struct devices
directly simply because it's way more convenient for the caller. That's
what find_parent_pci_dev() takes care of (it returns false if the device
is not a PCI device). Whether that's appropriate here is hard to say
seeing we haven't seen any caller code.

Logan


