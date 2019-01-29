Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CACE9C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:24:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 897FC20882
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:24:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 897FC20882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B7D38E0002; Tue, 29 Jan 2019 14:24:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38EF08E0001; Tue, 29 Jan 2019 14:24:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27CF78E0002; Tue, 29 Jan 2019 14:24:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id F369E8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:24:20 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id g7so16372439itg.7
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:24:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=f/wvjMae4YBnbSrh5OvDTPMZ1JXATYuOiaPl7zoSCAk=;
        b=tUcFaat9N6mM0MpX1odrHRl1poBftZ/DrzduXjYhxZr/Vgs6iGS7eM558XrwLk5Sw+
         jT2uJ9ES4+7py0EDuZJITOVpQZBJ2xq7eftd25CpzBibx0fxOZg+x7OocKUhq4wvRpqg
         w066/dYiCZudVGk5NUKKI7dg36tmYGtvMhC8Q8/BdjL/5TgFJg4PDaf18alRvBuEFnDP
         hV7wHLmTa+xlX1JCEiFyUIxYa05Xb9lm0gpccRUXZ9KfLwumvr3RWhlZfKdVM/48PSOH
         nLI9Q/gQriQ1IZ3yku7hRAObiB+QD1zWtGxqWWVD2pxtMTC/sHCk+kw2OKBNNrgVr13B
         Lopw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAub8/zyK5VwfqgoFbTaoOIB2RWZ4jkcM+05dl6VBqVEpDYoFDuAw
	YgF0JtbE9N4vRyZRFLe1D+MkLDaHaOnjNTXntVmprqss5UxNwtNZPiY0Cog3QEc663D7hwYSRxd
	3tNElAjQG43DbXl6W4GevBicTgAQQHbiE7aHV+XPcIj56Cey/t2/pZq3J3itytuQUcw==
X-Received: by 2002:a24:5d08:: with SMTP id w8mr596995ita.90.1548789860679;
        Tue, 29 Jan 2019 11:24:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbrNNq0XlLas+slKaJIATSd3cFH4PN/lO007fkUR4VlKqhi3aJuVpbaNx5LI33GsRYnG8Be
X-Received: by 2002:a24:5d08:: with SMTP id w8mr596966ita.90.1548789859957;
        Tue, 29 Jan 2019 11:24:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548789859; cv=none;
        d=google.com; s=arc-20160816;
        b=IxQUMH70zsb19YbBvhDkQpttm0A/rLfIEfgBuJtLEpACIqK6SIIbpCXiBjzr/PfTo3
         bnWOOWmvEBD77VNcSXqLie+eS9W8J46xKmFdVczh+xBpWnSVDQwbSPT0Gw1VAt8JI/iR
         m9ex+n+kNYcnm23oYOn5wFZgOcWs59+aqxseRigyjbfR9DaXaSbwtpIt0bSDU7tq89Qd
         hvQLvVDVi+CTmSu4HkzmiQQr25cMSWwYwzuo41r8qS4PivngkZTPk4yh155mw3B9qk3K
         5/Et7j5Xzgm/lXrdORyFmiA7NUavg0OiSqe7iLuOFaETEfFB8CofVf60K4gj6mq/F5YA
         hZmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=f/wvjMae4YBnbSrh5OvDTPMZ1JXATYuOiaPl7zoSCAk=;
        b=QDtgjeoVWsBw3tQ1BZrCEBfkYOxrFX04Ry0d8R3gX8vpCdHSAWWmeYDnbZEaNiMqjR
         bA1sVi/D5UpSHShhyOLrnJrzxNoNqliQgL9vKF4sNha1BFtgXyR+3xRbDa1iWA+HdxG7
         BBE83ggS/uQQRpzYKdKtbWISlJ2Ea0yhvlIcUZ7bU8Am6JDYdkxRi16UMDxH+9u9kLvt
         vl1Bm9cr72qVaXP3DJw3gR6LxY2Z/4NkBNdRpkWy2tvFkHFOLDPeJ9xvAJIQEytXmben
         83Ybp6NGzNHYrajKEzKVHjgqoBmw7gJpsrejVYf0Sqd2N/9x/VjiFE6kO4On6KLXAxDH
         z9nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 138si374526itm.79.2019.01.29.11.24.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 11:24:19 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goYzN-0005nT-QG; Tue, 29 Jan 2019 12:24:06 -0700
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
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
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <c2c02af7-1d6f-e54f-c7fb-99c5b7776014@deltatee.com>
Date: Tue, 29 Jan 2019 12:24:04 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129191120.GE3176@redhat.com>
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



On 2019-01-29 12:11 p.m., Jerome Glisse wrote:
> On Tue, Jan 29, 2019 at 11:36:29AM -0700, Logan Gunthorpe wrote:
>>
>>
>> On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
>>
>>> +	/*
>>> +	 * Optional for device driver that want to allow peer to peer (p2p)
>>> +	 * mapping of their vma (which can be back by some device memory) to
>>> +	 * another device.
>>> +	 *
>>> +	 * Note that the exporting device driver might not have map anything
>>> +	 * inside the vma for the CPU but might still want to allow a peer
>>> +	 * device to access the range of memory corresponding to a range in
>>> +	 * that vma.
>>> +	 *
>>> +	 * FOR PREDICTABILITY IF DRIVER SUCCESSFULY MAP A RANGE ONCE FOR A
>>> +	 * DEVICE THEN FURTHER MAPPING OF THE SAME IF THE VMA IS STILL VALID
>>> +	 * SHOULD ALSO BE SUCCESSFUL. Following this rule allow the importing
>>> +	 * device to map once during setup and report any failure at that time
>>> +	 * to the userspace. Further mapping of the same range might happen
>>> +	 * after mmu notifier invalidation over the range. The exporting device
>>> +	 * can use this to move things around (defrag BAR space for instance)
>>> +	 * or do other similar task.
>>> +	 *
>>> +	 * IMPORTER MUST OBEY mmu_notifier NOTIFICATION AND CALL p2p_unmap()
>>> +	 * WHEN A NOTIFIER IS CALL FOR THE RANGE ! THIS CAN HAPPEN AT ANY
>>> +	 * POINT IN TIME WITH NO LOCK HELD.
>>> +	 *
>>> +	 * In below function, the device argument is the importing device,
>>> +	 * the exporting device is the device to which the vma belongs.
>>> +	 */
>>> +	long (*p2p_map)(struct vm_area_struct *vma,
>>> +			struct device *device,
>>> +			unsigned long start,
>>> +			unsigned long end,
>>> +			dma_addr_t *pa,
>>> +			bool write);
>>> +	long (*p2p_unmap)(struct vm_area_struct *vma,
>>> +			  struct device *device,
>>> +			  unsigned long start,
>>> +			  unsigned long end,
>>> +			  dma_addr_t *pa);
>>
>> I don't understand why we need new p2p_[un]map function pointers for
>> this. In subsequent patches, they never appear to be set anywhere and
>> are only called by the HMM code. I'd have expected it to be called by
>> some core VMA code and set by HMM as that's what vm_operations_struct is
>> for.
>>
>> But the code as all very confusing, hard to follow and seems to be
>> missing significant chunks. So I'm not really sure what is going on.
> 
> It is set by device driver when userspace do mmap(fd) where fd comes
> from open("/dev/somedevicefile"). So it is set by device driver. HMM
> has nothing to do with this. It must be set by device driver mmap
> call back (mmap callback of struct file_operations). For this patch
> you can completely ignore all the HMM patches. Maybe posting this as
> 2 separate patchset would make it clearer.
> 
> For instance see [1] for how a non HMM driver can export its memory
> by just setting those callback. Note that a proper implementation of
> this should also include some kind of driver policy on what to allow
> to map and what to not allow ... All this is driver specific in any
> way.

I'd suggest [1] should be a part of the patchset so we can actually see
a user of the stuff you're adding.

But it still doesn't explain everything as without the HMM code nothing
calls the new vm_ops. And there's still no callers for the p2p_test
functions you added. And I still don't understand why we need the new
vm_ops or who calls them and when. Why can't drivers use the existing
'fault' vm_op and call a new helper function to map p2p when appropriate
or a different helper function to map a large range in its mmap
operation? Just like regular mmap code...

Logan

