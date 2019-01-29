Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDFE3C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:25:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C2AA20880
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:25:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C2AA20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 400EB8E0004; Tue, 29 Jan 2019 15:25:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AEB88E0001; Tue, 29 Jan 2019 15:25:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A1088E0004; Tue, 29 Jan 2019 15:25:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id F1A928E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:25:03 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id s3so17611733iob.15
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:25:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=DAbYKTTDsRFKBrrEeJAxFsfJ5sQigQTed9Xbt6PPYHY=;
        b=BJlEpaw3Y05MFSdw5Y7Cz/l2VSNp4wOaS6f7YU8JGLukpeeh08ZisPIbX7MgSik6HV
         gofaivC+K6DinA3qlM4ZcfdWp7N4PSWqKtkTQNBT10Z1QJ2YmlR3Zx9Lf7xl//nY00eN
         UYlljoWYUccqjS3nasVsSlChysqVAlB7bYZX5ET/E7SeGCFLXveC7hVyGP/BqgWqg38G
         1a8A5FblTa/jpmN9u4KTMj92fkYF1UOMKdSpTn2YDcZJEv6b8P27WYw2TPpwb2pZER7G
         5EAMP58p9/jlX5Fx+Z7JJz3gxHBYh7q6TQ+yWteEiTyVsJyR/vyhK7xBOwiLwVk6TARC
         zxvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AJcUukdkGi7ufNbefuMvqvsB804OzP5J8IVbrZqziG88GdXvqdGJtqwn
	wUcSXA4Kc5Irq7RBwNVqzA1GE0fcpMbstptTR5d9s1K16BwFRx8/Bhq6hSpnrUwViRypS4RCZcv
	7+lAzBMet6/jmC35upL/t6RYZKY7HMqp2euLOjAdZPXmMeovqU2S+iZmFUI6njZj+Fg==
X-Received: by 2002:a24:97c3:: with SMTP id k186mr15137807ite.125.1548793503772;
        Tue, 29 Jan 2019 12:25:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4L8R6sxos7PLYFaxYvOD7qtwE87FnY14sZFUbQTdXKFP5UazSrZtf95JpatTItfsjs0+xb
X-Received: by 2002:a24:97c3:: with SMTP id k186mr15137764ite.125.1548793502683;
        Tue, 29 Jan 2019 12:25:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548793502; cv=none;
        d=google.com; s=arc-20160816;
        b=G5em99wFBl1M9pVYoxrnBrRjgPjFpVsglV5YGNU5d8OvHFSVFyBjiLqkuXetxRhq37
         YQ/V57O+Mu6EgKG5ZYbZrSYJzvNP0cHB+gJA8jxggyNzUENzz9CEKnXP98HyhizvY+ev
         W95bIm7jU4cE2Cd7F5Rk60GsiECpN2Mef7uwuxbROvL9cL/YZnoDAV6hpUk+WkPLD5sM
         0G1JTcs24z9aMHd4Bl6soIwGoikp/DXHWoZkrS8wyp7YT/Hz1QDMyfRWOtuRpVv+gyNj
         t2PnX/7MIj206p6rtK3LKk3Ir1P7+mIq9d6eopEs3Of4fm8xbC+wzm5iJ0gdMaMY/Fbk
         MY7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=DAbYKTTDsRFKBrrEeJAxFsfJ5sQigQTed9Xbt6PPYHY=;
        b=MDnGOm3Wh7xs78g7VEWF/q9JbvSabmKCz1rynxCdD9IagiSRrT7LRfZLQThtq7VGrN
         RNT78qCTFRqY7LxdsuCkfDrjgAj57oSYVeGW3DT8APqsVaxImbmmeDAv3I9GwkWDuF2q
         9lsxLpJz1oECcK9catAfMjbWyh/81SPmx8hU51gSmKN+wYz3R+H0qw6rsVwM2znuQPsU
         Faral7US21nk/6aEE0S4vmrqPb8XCvqRumx0aIFIomzmYa1jhzoRnja5TqfWEV7ab2RO
         HwBuaHyMDH6AN5ijPEb+sVcQ+Jtx8iAPU+9Jsg4B8d2q9LqNCt+xIIapkEqAqwyBmYFy
         s8wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id l187si21430385iof.132.2019.01.29.12.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 12:25:02 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goZwA-0006Yf-64; Tue, 29 Jan 2019 13:24:51 -0700
To: Alex Deucher <alexdeucher@gmail.com>, Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Joerg Roedel <jroedel@suse.de>,
 "Rafael J . Wysocki" <rafael@kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Felix Kuehling <Felix.Kuehling@amd.com>, LKML
 <linux-kernel@vger.kernel.org>,
 Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
 Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org,
 Jason Gunthorpe <jgg@mellanox.com>, Linux PCI <linux-pci@vger.kernel.org>,
 Bjorn Helgaas <bhelgaas@google.com>, Robin Murphy <robin.murphy@arm.com>,
 Christian Koenig <christian.koenig@amd.com>,
 Marek Szyprowski <m.szyprowski@samsung.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-2-jglisse@redhat.com>
 <CADnq5_N8QLA_80j+iCtMHvSZhc-WFpzdZhpk6jR9yhoNoUDFZA@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <83acb590-25a5-f8ae-1616-bdb8b069fa0f@deltatee.com>
Date: Tue, 29 Jan 2019 13:24:48 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CADnq5_N8QLA_80j+iCtMHvSZhc-WFpzdZhpk6jR9yhoNoUDFZA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: m.szyprowski@samsung.com, christian.koenig@amd.com, robin.murphy@arm.com, bhelgaas@google.com, linux-pci@vger.kernel.org, jgg@mellanox.com, iommu@lists.linux-foundation.org, hch@lst.de, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, Felix.Kuehling@amd.com, gregkh@linuxfoundation.org, rafael@kernel.org, jroedel@suse.de, linux-mm@kvack.org, jglisse@redhat.com, alexdeucher@gmail.com
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



On 2019-01-29 12:56 p.m., Alex Deucher wrote:
> On Tue, Jan 29, 2019 at 12:47 PM <jglisse@redhat.com> wrote:
>>
>> From: Jérôme Glisse <jglisse@redhat.com>
>>
>> device_test_p2p() return true if two devices can peer to peer to
>> each other. We add a generic function as different inter-connect
>> can support peer to peer and we want to genericaly test this no
>> matter what the inter-connect might be. However this version only
>> support PCIE for now.
>>
> 
> What about something like these patches:
> https://cgit.freedesktop.org/~deathsimple/linux/commit/?h=p2p&id=4fab9ff69cb968183f717551441b475fabce6c1c
> https://cgit.freedesktop.org/~deathsimple/linux/commit/?h=p2p&id=f90b12d41c277335d08c9dab62433f27c0fadbe5
> They are a bit more thorough.

Those new functions seem to have a lot of overlap with the code that is
already upstream in p2pdma.... Perhaps you should be improving the
p2pdma functions if they aren't suitable for what you want already
instead of creating new ones.

Logan

