Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CBBDC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:36:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA7EB2080F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:36:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA7EB2080F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 712A08E0003; Tue, 29 Jan 2019 13:36:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6999C8E0001; Tue, 29 Jan 2019 13:36:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53DDD8E0003; Tue, 29 Jan 2019 13:36:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25ADC8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:36:47 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id u2so17255851iob.7
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:36:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=V6Z/wRHo/U8m5UN+kVHpwNydZnYAX4xhGlD7cv4FSiU=;
        b=sXDMaIeltYrgmv041NHsJvFK5eNaQGsgkHwB2iGf++AZbQsjFEwR8Nl//rXhV78M8N
         TFV3VAUSTumf8q0YGKUybUtwCmH5GR3LR0EnZBHe42BO+x7w3ZBfAfzGAyHz7mMFgyrR
         ztyyYLVh2a8lL28LV5hNMB32PZ/G2rjjFhJ5KiiK/FvU8V8lrxKe3Ka5XDpH0+VmHNCq
         ApPesFkVsZzPyN4P21D7THPD2YkSeaEw+7ka9S43axMDP5hclwrQ8oA/2E7jDCr4WLxa
         HbvdnsNVd5aqMvOw06ugE8cAZI6U9ucs4wwx7sPrrTRB7x+ppf7bNShfLozrzQynYFFM
         kluQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAuZJPXkrMpZEKrUh1R7R6RNCz1AY3ZC0Qtp9sdhYYFpKmmZNt/0h
	rA3qf4lz5ocRS171Ro50RNDOMnAGTYP60hTXhkXUzkv6/yS8FM+MLJXbXc6t1M0jXHKPq4DNz4N
	C+LxOTRZzYYV9gLYXRncxyqsldVcPDyVjWszaJJfUL7U0l08st1psZ/KyOdXBQF3NxQ==
X-Received: by 2002:a6b:c402:: with SMTP id y2mr17154137ioa.77.1548787006883;
        Tue, 29 Jan 2019 10:36:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5STPLyRP/cUntuL/a0fN9vlSoRQey8E2/JUx101SYbAsKAwcdGalQZiR/rVsuGvGPsjeJm
X-Received: by 2002:a6b:c402:: with SMTP id y2mr17154117ioa.77.1548787006139;
        Tue, 29 Jan 2019 10:36:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787006; cv=none;
        d=google.com; s=arc-20160816;
        b=e2QDcpwcahUfTpUWoRcFmlXCp23hV/9+F1hFwIqwsKc8wKoJP7NRgj1NmXYpUeyhPM
         qxIDppEyyiRc+sVZgLTtBwuOXXjfw75+nnaxwT5KdV0Mn/Pq68ht+hRpUiH9NJPSnoH7
         XVBUXbSzlx9zmtaexLaLgJ627dAwFMO+IT2/LSb8mGJxLc/uE+8kxqSNXa1E4CRp+jfh
         2y7m01mSTX7WGsYZxTpOXRWbcJGz5fetqcn7ee8KdwOLqjcaTKnFNvOEKuJyOs9udRVI
         qhANp9R0ayaUJniYmTecoksxpPfxbnerNUIgO8Fcb5nU6eLM7/Q9X6mdz6VsMHPrpJhr
         L69w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=V6Z/wRHo/U8m5UN+kVHpwNydZnYAX4xhGlD7cv4FSiU=;
        b=tD2npavDh3T0oOOAl63TqUZ+pjRFf2Z8S0ePIviXu6zIqbnIbNWlmmo0qycLNNdNWN
         KOSiAatgVDs9NNgpb2Dyxwe3laa0F4l1eQVkViboMfDdG8FlOWTZ4IsHLvViLnN/ecIG
         kl6wO9uQXaotefodEM/+iH8ysYOGdNls8fyES9DRTJLLqQG4rZSnoJ2Wx/cAzjXWzXl3
         NJmcfyB3f7MRXiivIskMCvvMh8kztQ33p/mBPAWkJUXywx932tt5jVyXZdW2u4csHBIK
         Sq2kdfoAj6xUUsFj1xhd8/bESBU2m8jNgaOcgB2TbrI3TB2ukqatccgUDJGExmTKQ6Ve
         Hz6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id l20si4177590iob.67.2019.01.29.10.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 10:36:46 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goYFK-00057p-St; Tue, 29 Jan 2019 11:36:31 -0700
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
 <20190129174728.6430-4-jglisse@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
Date: Tue, 29 Jan 2019 11:36:29 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129174728.6430-4-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, hch@lst.de, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, jgg@mellanox.com, Felix.Kuehling@amd.com, christian.koenig@amd.com, bhelgaas@google.com, rafael@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:

> +	/*
> +	 * Optional for device driver that want to allow peer to peer (p2p)
> +	 * mapping of their vma (which can be back by some device memory) to
> +	 * another device.
> +	 *
> +	 * Note that the exporting device driver might not have map anything
> +	 * inside the vma for the CPU but might still want to allow a peer
> +	 * device to access the range of memory corresponding to a range in
> +	 * that vma.
> +	 *
> +	 * FOR PREDICTABILITY IF DRIVER SUCCESSFULY MAP A RANGE ONCE FOR A
> +	 * DEVICE THEN FURTHER MAPPING OF THE SAME IF THE VMA IS STILL VALID
> +	 * SHOULD ALSO BE SUCCESSFUL. Following this rule allow the importing
> +	 * device to map once during setup and report any failure at that time
> +	 * to the userspace. Further mapping of the same range might happen
> +	 * after mmu notifier invalidation over the range. The exporting device
> +	 * can use this to move things around (defrag BAR space for instance)
> +	 * or do other similar task.
> +	 *
> +	 * IMPORTER MUST OBEY mmu_notifier NOTIFICATION AND CALL p2p_unmap()
> +	 * WHEN A NOTIFIER IS CALL FOR THE RANGE ! THIS CAN HAPPEN AT ANY
> +	 * POINT IN TIME WITH NO LOCK HELD.
> +	 *
> +	 * In below function, the device argument is the importing device,
> +	 * the exporting device is the device to which the vma belongs.
> +	 */
> +	long (*p2p_map)(struct vm_area_struct *vma,
> +			struct device *device,
> +			unsigned long start,
> +			unsigned long end,
> +			dma_addr_t *pa,
> +			bool write);
> +	long (*p2p_unmap)(struct vm_area_struct *vma,
> +			  struct device *device,
> +			  unsigned long start,
> +			  unsigned long end,
> +			  dma_addr_t *pa);

I don't understand why we need new p2p_[un]map function pointers for
this. In subsequent patches, they never appear to be set anywhere and
are only called by the HMM code. I'd have expected it to be called by
some core VMA code and set by HMM as that's what vm_operations_struct is
for.

But the code as all very confusing, hard to follow and seems to be
missing significant chunks. So I'm not really sure what is going on.

Logan

