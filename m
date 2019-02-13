Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0F7EC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 10:17:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 689F7222B5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 10:17:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 689F7222B5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3F0C8E0002; Wed, 13 Feb 2019 05:17:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEC788E0001; Wed, 13 Feb 2019 05:17:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8E8A8E0002; Wed, 13 Feb 2019 05:17:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8C28E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:17:09 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id l8so1560475otp.11
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 02:17:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=ITu/ESLuWRDoflJM0KJPL4ID9Jf0KN0TP3jjmMOqqaA=;
        b=LHBbdA38VzroGtXtmAzwl+UMQm68qDS5d8I3Cm3DQPUAUpYvFpWT5up9YJr7ERj0uw
         adlXv77AIuWmrDhegSqGBfC/O2F9iWYvS41zObj8SA2UXpoDW4sSHR8ZjT6WUcZlkaBs
         FASpWrcvmsQ2Z3y5CMDRm1nWpWcL2M9BVQ0dxjBqOr/YF5QQDrm7FiVEhG3BpWO5lBeu
         GyMBspp+++irjjjv4hkO3oxdiskFZVkJtrnfS0lo8fj/WHNvI306jI9I0WvOWTRssNjk
         q60o8exHnMBr6ux67nuVyll/fEJg8Hzxr34sBXCFCmwX3us2HmoyhS9WniWS4+dreybL
         bWlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuaerxgnxQz5lAm7Bw18S/vSQVN0PZlYj3XjfNZu3oSJWYL/02Hh
	lhQI3tpAW/8vM2p4+jQG4HPQncJ1A/gkt7jDhwYGzeN2y/FvwlanCiTjjT29ZYwMYYLGE6pXaay
	cwCGX07wcx5nSSO2SUvIOxzExUQywSNhu0ieH0VWGtzNio8mOC1Dt9CCsATaY+3rQJA==
X-Received: by 2002:aca:37d5:: with SMTP id e204mr713662oia.134.1550053029216;
        Wed, 13 Feb 2019 02:17:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib5S15FFrpeokW1/73R7d+RXbxJfJ5JKwrIcwAh2Hh9YmUFGpZnTAxIxy+ZRI8J0h6XSayV
X-Received: by 2002:aca:37d5:: with SMTP id e204mr713637oia.134.1550053028397;
        Wed, 13 Feb 2019 02:17:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550053028; cv=none;
        d=google.com; s=arc-20160816;
        b=0gR519fPcMtf6JMgqIoBMTSvft6ikiZ6F7wZlFpCBsNt36KzAZi2YfaBVH5uuOgvUw
         DX23/oUke3G9qFW/a3cjPuilRazKoUpbBHbyQUe+OkUK/tgF0C+ebgHZZB5+dmSugCuD
         cPa8bRqaLukc+AjrPwD8oTo/O8LQbiBwWe1PsoWgloVQjEBZ+nc4kjn4+SJUVqwZXYp6
         V7HldjdQtT+E52rdJTiF+OqfJps0dvgFWov1KFs0hZ7EJt1cE/CIvdjDLLomLkGAaBwC
         6OelneTqGS4rLr0nhJJIC3vLWZETORKSPGV0YFyyW8Rjg9uBNAzeB+k79sZb4eqmSEjj
         BzRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=ITu/ESLuWRDoflJM0KJPL4ID9Jf0KN0TP3jjmMOqqaA=;
        b=vHbUaRskBkdnesESlqhDOWPDMfvBSjWqePpgcWdKgloMmRa21OJDCYwsnqAXDL0zl8
         mgp5JhXdWUPmfqDVBQoy04oBDbKWUdf5+PhrESSqVp+gdJgRqBOYgUe/jzH2+rjARySy
         VdheN5CwuEXFfSvJmHlbko9kB2EPjl+9yNpcZFrkb9p7QBETfVYJ+jZJGf2VWtfPeF3p
         ENA9hOcuBKL5w7+VPTIL0ybS4miI7CRXJg4ETYyQYi50Kjt5no8xfO4YMgiudr0djkHd
         rznD0sMiOu/OWCRA37JiQJ/fIX69vGZ3T6WoqO5dZZL9iTozZOIYoig9ou6z727t8q9L
         VLyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id 59si6626059ota.290.2019.02.13.02.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 02:17:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 62BE13A9832A82393620;
	Wed, 13 Feb 2019 18:17:02 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.408.0; Wed, 13 Feb 2019
 18:16:52 +0800
Date: Wed, 13 Feb 2019 10:16:40 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>, =?ISO-8859-1?Q?J?=
 =?ISO-8859-1?Q?=E9r=F4me?= Glisse <jglisse@redhat.com>, "Rafael J . Wysocki"
	<rjw@rjwysocki.net>, Michal Hocko <mhocko@kernel.org>, <jcm@redhat.com>
Subject: Re: [PATCH 1/3] ACPI: Support Generic Initator only domains
Message-ID: <20190213101640.00006a51@huawei.com>
In-Reply-To: <20190212214736.GG6176@localhost.localdomain>
References: <20190212164926.202-1-Jonathan.Cameron@huawei.com>
	<20190212164926.202-2-Jonathan.Cameron@huawei.com>
	<20190212214736.GG6176@localhost.localdomain>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019 14:47:36 -0700
Keith Busch <keith.busch@intel.com> wrote:

> On Tue, Feb 12, 2019 at 04:49:24PM +0000, Jonathan Cameron wrote:
> > +	case ACPI_SRAT_TYPE_GENERIC_INITIATOR_AFFINITY:
> > +	{
> > +		struct acpi_srat_gi_affinity *p =
> > +			(struct acpi_srat_gi_affinity *)header;
> > +		char name[9] = {};
> > +
> > +		if (p->flags & ACPI_SRAT_GI_PCI_HANDLE) {
> > +			/*
> > +			 * For pci devices this may be the only place they
> > +			 * are assigned a proximity domain
> > +			 */
> > +			pr_debug("SRAT Generic Initiator(Seg:%u BDF:%u) in proximity domain %d %s\n",
> > +				p->pci_handle.segment,
> > +				p->pci_handle.bdf,
> > +				p->proximity_domain,
> > +				(p->flags & ACPI_SRAT_GI_ENABLED) ?
> > +				"enabled" : "disabled");  
> 
> <snip>
> 
> > +#define ACPI_SRAT_GI_ENABLED     (1)		/* 00: Use affinity structure */
> > +#define ACPI_SRAT_GI_ACPI_HANDLE (0)		/* 01: */
> > +#define ACPI_SRAT_GI_PCI_HANDLE  (1 << 1)	/* 01: */  
> 
> It looks like you're reading reserved bits. My copy of the 6.3 spec says
> PCI Handle is 1, and is set in Device Handle Type field, not in the Flags.
Good spot.

Sorry, wrote this long before spec publish and some details got tidied up.
I fixed iasl end but forgot to actually update the reading of it. Oops!
As you can probably guess that my test was using an ACPI handle so didn't
hit this at all.  I'll shove a PCIe card in the machine to check those
as well.

Will fix up for v2!

Thanks,

Jonathan
> 
> > +/* 5 : Generic Initiator Affinity (ACPI 6.3) */
> > +
> > +struct acpi_srat_gi_affinity {
> > +	struct acpi_subtable_header header;
> > +	u8 reserved;
> > +	u8 device_handl_type;
> > +	u32 proximity_domain;
> > +	union {
> > +		struct acpi_srat_gi_acpi_handle acpi_handle;
> > +		struct acpi_srat_gi_pci_handle pci_handle;
> > +	};
> > +	u32 flags;
> > +	u32 reserved2;
> > +};  


