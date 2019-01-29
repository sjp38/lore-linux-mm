Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D72AC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:26:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1A2420869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:26:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1A2420869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98E048E0004; Tue, 29 Jan 2019 13:26:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93AC98E0001; Tue, 29 Jan 2019 13:26:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DCEF8E0004; Tue, 29 Jan 2019 13:26:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 56CF08E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:26:15 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id s3so17352761iob.15
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:26:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=axl1zznr0w9UZiVfAcrbtJhjHOz7hPohZklvkARJjLc=;
        b=Cp81f1G62nLoFWymIHc+yW3CHndGw5ODjcezlnygvdo8Ovy1f5tb9+FIuuaMGLt6uv
         Lgbn3HDlyvSl8g3Gp+6pb72RSu0STBoW0t9RRk+Gza/tNmSxe3wKPtT5xPtrr0Wf9XPe
         CJiJTUHKBuVVZUZtV/eggicpkg7gVyZi9vIDqdZuNlBYUjTm+Dxm+lpK+mtzkWHVEV25
         uulpdV9bV4TRDTeUVmgTyghJhkrRLlDRtZnrYfsoZdrUYnxpt6mXUST5pP2DLTSzA3cu
         +QUmUrb1x0vdqsQznoC5b2T8vCcD3RlrOAKIOh7Q/tFv23XxpW0jrslDiTq5aCuIRRXl
         IsNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AJcUukezdbFEzJS5zQx1BSHstTDFXll9nGu5iQbNLxBvta3OIOSX88wW
	ezLJo2PJ6eX1Ghit4qo8bIrXI+EHn/OZ55pXAzaCjzssWNIdmK8Jez+98mD92xkfA5snNG1Z6DH
	1OJgBr35UJaQqo1Dy/rSvL5K2R7EQhoxu45cd3EGv48A5GeO5JfE89ESt6h9C44+0wg==
X-Received: by 2002:a24:784a:: with SMTP id p71mr15710783itc.158.1548786375163;
        Tue, 29 Jan 2019 10:26:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4tT36Smbf4yGg6G4FN7jO4kxabXoAIPV6Yz3IaZjkPN56zidqGpB1wiXsokTgEobx70Jgt
X-Received: by 2002:a24:784a:: with SMTP id p71mr15710762itc.158.1548786374562;
        Tue, 29 Jan 2019 10:26:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548786374; cv=none;
        d=google.com; s=arc-20160816;
        b=v+CoQG/ccXFqotHSc8zc3aGDwXfQAVSQ+DmqH0s4QX/Uy7cJOR1Moal7Wum9VfpGAd
         WVRnnaPnJCw2mg7quaF2Lb7Ca9vCdiC7U3drM/oi6liNm/9ZeV9JWgF188Th2AkA8buz
         7r0F4WX0m/LwnVj3rpdlgu6GaDDFVWVAbeuivZSX96xjNi4JAvyNMra9oOLNXj0AYgEG
         jMKXWRFmcyCz/wCjZCMXdlB/JBcqX90qu6TLHg1znb8V1zOzsRG0Wp4c65Hm6h+6mscn
         f92GmP9tEsQbrcKt1OyIhgHW8MRcmmPGaE4f8JeFfqnAVZkWkkuFaJcvb75ipvJPi9My
         oLbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=axl1zznr0w9UZiVfAcrbtJhjHOz7hPohZklvkARJjLc=;
        b=cnKsH8M8RlkhTsDjLDwF49ksvS0Ye+/XBwh+QVejMz6866A7h1ravbid1hvk3j5QIX
         8SxcLTDfNlR6fKAN29aic5+1K7V92o5pOE69JF1trQClbz/HoKDmwCY6OuCNR+m3j5bC
         rZsA1n/001mKhjODfzk78Zz2GXBxIWaz/9rvwMWjKBhf/PksLv4divi2qm4MXZnh62SX
         pL9EHLborMM4V91LdHLGufwL8FS+58TlgR5dMVsx5DzvJjiImvfwUvbR5mHFtFfL+mw6
         Rlj+6Z9VysUjdGw5nLO9uyXXIazS69FSw3qeu8X+EOX5/h1cJ3gSSyA1j6H2K6GVIOW1
         q/pw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 13si50154jat.33.2019.01.29.10.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 10:26:14 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goY5B-00053B-Qg; Tue, 29 Jan 2019 11:26:02 -0700
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn Helgaas
 <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>,
 linux-pci@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>,
 Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
 iommu@lists.linux-foundation.org
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-3-jglisse@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <98d345af-7928-2a50-7bc4-582916dfac80@deltatee.com>
Date: Tue, 29 Jan 2019 11:26:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129174728.6430-3-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, hch@lst.de, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, jgg@mellanox.com, Felix.Kuehling@amd.com, christian.koenig@amd.com, bhelgaas@google.com, rafael@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [RFC PATCH 2/5] drivers/base: add a function to test peer to peer
 capability
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> device_test_p2p() return true if two devices can peer to peer to
> each other. We add a generic function as different inter-connect
> can support peer to peer and we want to genericaly test this no
> matter what the inter-connect might be. However this version only
> support PCIE for now.

This doesn't appear to be used in any of the further patches; so it's
very confusing.

I'm not sure a struct device wrapper is really necessary...

Logan

