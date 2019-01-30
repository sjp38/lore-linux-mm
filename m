Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6D47C3E8A4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:25:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74022218AE
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:25:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nQeWgZG+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74022218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 003778E0002; Wed, 30 Jan 2019 05:25:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF5E08E0001; Wed, 30 Jan 2019 05:25:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBE0D8E0002; Wed, 30 Jan 2019 05:25:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86A048E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 05:25:37 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id 51so9093530wrb.15
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:25:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:reply-to:subject:to:cc:references
         :from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=HMfAj4RzlX1XnDfgUELyfPYynmQa4PT0FdtcX8nLAvg=;
        b=kvad4PhECPT1fqYh84cXQflYBicrmar2LEdiyrR05JHHTC9SRYmmydYqiFtxGp3TIQ
         TZJwN1NM+0Ob9K84tldbfSMhG0iD/Gf4prwwKqnnGXkOWysW3m04Wu0FYfa1kguE79PB
         ZxYmvT83OKvJ7UAzeuvAuO6zCZjzGYcbTnygYZKiWhVeVNQXSpngAl2hZZ6nYa0HsMbT
         oKAM764jD5eeMCWIRddHLtBd+AETxQFdeWoqm04MKdiKnwEA8xyxKbVRn8YHLddxm0hC
         LjOdwKnck2eX3ex7ePq2+ltyqb/AmvXolrXR+2h3oBn6hQ6pTkPU7zp9kw39SJkGFvxg
         /GWg==
X-Gm-Message-State: AHQUAubHDQug1bw6Agj1ze0A7X6omjV63df+Jytj0isSBvulvOxjF4//
	K8LNdruIQQeE46moqviLrgVNpOAJja5psJdWucysCoCTGFoJzGzGdkVWLLQdbCXVxpBcx3hrF3Z
	dCwxFtWeLR8oJ7ixb9nC275aVuEyBfb6+6hFJCaRA2NwPMNcT1nxZQl/PJ3KTOLBgTkNyLGjz90
	eAvDntVqIYal7cN+PfQxAarY/+NbC4rm/kSj4eQM5mJRTZqh5hRR919AOAtL1cXx5gXZPonX+O/
	G9Hd+JHjnavaNRPzhz2nhtuyOpyR3bAJVXSgSSpFfzoXVhj2EmzyyjkIDoCLvtTCeT6kPB+jd2l
	ZrPYMRF2T1DzQ1G0rnf44OqYL2DKZ9ad0arenRjG2jApG70NdMR0DDM+t7xySDMqR0+ouJMdM17
	P
X-Received: by 2002:a1c:f50a:: with SMTP id t10mr2501208wmh.126.1548843937080;
        Wed, 30 Jan 2019 02:25:37 -0800 (PST)
X-Received: by 2002:a1c:f50a:: with SMTP id t10mr2501159wmh.126.1548843936283;
        Wed, 30 Jan 2019 02:25:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548843936; cv=none;
        d=google.com; s=arc-20160816;
        b=OiTkIQI6EUAAjW/5Nhf4pSTFAfkGeyRpFOw+l3R3mfGCANGrREEUdISduT5/koH7fJ
         U1TKcOkRjYRvVqM7wH/i8mXo1Dem2KKecDryycymdYGSrxKAH7ZoFokjq0DYhfi4Rs93
         ESp60dvlw76tayybJTkkVAufkWxx2YgqoQ6pxPypm1AnSZamDWyIDPZm3FCvSEU52Ugo
         tSy8jXUpvqQDRWhTGmUlUeiBVgMGIsCB0rvyU9+ZAScfBcr5nUQkmzYru4fl6PXLlgpG
         s4gqm4M1jUDYDRYWEYBokhMQgrr4ws6R/7Cza58iVIHn65FmKUoc/kMUFB6AJBjc75O9
         TvXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject:reply-to
         :dkim-signature;
        bh=HMfAj4RzlX1XnDfgUELyfPYynmQa4PT0FdtcX8nLAvg=;
        b=blObVU5/z/428hJ7gP7bs53l8VaARrV5YC5b8yb9X8HDdVf8dDFezx65PH4w3HNNwf
         ksIgesD2jlNvf1hxcRUmQ19KWQflS+jJxIRPLhObUIyVXoD+HmxCEJ7W/NFaTXw9RHhk
         6BhiV1jflGsja2Gwbc37tEgYkaad4eE6Cg2PwJvgTTykzBOcPt4g6QXK8dOJN0Gdxt4u
         rKSAbDjFBUU0seP8KPTu5HMHKHtP0dI0pau4XA+dHDalj4nsVMvBfXqzALgJ1CiZIvqo
         T0LwVsqtlw/vQOFVy/HAH6UjSFM/M7rVEWT4V4wk1a6kmylcIdPBcWm4j68P1vdH/z9c
         uFAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nQeWgZG+;
       spf=pass (google.com: domain of ckoenig.leichtzumerken@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ckoenig.leichtzumerken@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b15sor1019639wmg.24.2019.01.30.02.25.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 02:25:36 -0800 (PST)
Received-SPF: pass (google.com: domain of ckoenig.leichtzumerken@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nQeWgZG+;
       spf=pass (google.com: domain of ckoenig.leichtzumerken@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ckoenig.leichtzumerken@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=reply-to:subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=HMfAj4RzlX1XnDfgUELyfPYynmQa4PT0FdtcX8nLAvg=;
        b=nQeWgZG+3okJ3xJP/5vtiHEjozfG9PNxu1TD1aBQ6Ti7TWdzgJl2Q3GvVpAMRKj/gG
         v8VmvqoUOflO8tKhAN+hVgGBm1P89zcR9zQUNE0NjWcnxyHSBBn8rOvgFsYFNTl5juKA
         r5qu3AQtx6M2I0xOOjyECQmKJ7nyG1rywSLDaDLospHbPc9RwQbRtL38x4uGb+cHv6sB
         dNsBLpPZOUTq57Rwc/KiVyXMYhrixeu8p26WfD0lPXUiyp6Uc7C5T7nVgAi841mhcnKN
         9ALOQy3epnrxWJJXr89K51wqUMPQWoiWI+uGj1KFif/arpEid/MQKSI1yVFjCMvtTXp/
         jtJA==
X-Google-Smtp-Source: ALg8bN7YvuWVZeFypre8aGXXvQP91o/M7l9lFXYWW0v/0gLd419E55sGFQXtn4PBsmBOuDaRwvY+iA==
X-Received: by 2002:a1c:be11:: with SMTP id o17mr24245832wmf.111.1548843935769;
        Wed, 30 Jan 2019 02:25:35 -0800 (PST)
Received: from ?IPv6:2a02:908:1252:fb60:be8a:bd56:1f94:86e7? ([2a02:908:1252:fb60:be8a:bd56:1f94:86e7])
        by smtp.gmail.com with ESMTPSA id y13sm665205wrn.73.2019.01.30.02.25.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 02:25:34 -0800 (PST)
Reply-To: christian.koenig@amd.com
Subject: Re: [RFC PATCH 1/5] pci/p2p: add a function to test peer to peer
 capability
To: Logan Gunthorpe <logang@deltatee.com>,
 Alex Deucher <alexdeucher@gmail.com>, Jerome Glisse <jglisse@redhat.com>
Cc: Joerg Roedel <jroedel@suse.de>, "Rafael J . Wysocki" <rafael@kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Felix Kuehling <Felix.Kuehling@amd.com>, LKML
 <linux-kernel@vger.kernel.org>,
 Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
 Christian Koenig <christian.koenig@amd.com>, linux-mm <linux-mm@kvack.org>,
 iommu@lists.linux-foundation.org, Jason Gunthorpe <jgg@mellanox.com>,
 Linux PCI <linux-pci@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
 Marek Szyprowski <m.szyprowski@samsung.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-2-jglisse@redhat.com>
 <CADnq5_N8QLA_80j+iCtMHvSZhc-WFpzdZhpk6jR9yhoNoUDFZA@mail.gmail.com>
 <83acb590-25a5-f8ae-1616-bdb8b069fa0f@deltatee.com>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>
Message-ID: <6739544c-0122-ad8c-d3cf-86a4d8a1d7a2@gmail.com>
Date: Wed, 30 Jan 2019 11:25:33 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <83acb590-25a5-f8ae-1616-bdb8b069fa0f@deltatee.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am 29.01.19 um 21:24 schrieb Logan Gunthorpe:
>
> On 2019-01-29 12:56 p.m., Alex Deucher wrote:
>> On Tue, Jan 29, 2019 at 12:47 PM <jglisse@redhat.com> wrote:
>>> From: Jérôme Glisse <jglisse@redhat.com>
>>>
>>> device_test_p2p() return true if two devices can peer to peer to
>>> each other. We add a generic function as different inter-connect
>>> can support peer to peer and we want to genericaly test this no
>>> matter what the inter-connect might be. However this version only
>>> support PCIE for now.
>>>
>> What about something like these patches:
>> https://cgit.freedesktop.org/~deathsimple/linux/commit/?h=p2p&id=4fab9ff69cb968183f717551441b475fabce6c1c
>> https://cgit.freedesktop.org/~deathsimple/linux/commit/?h=p2p&id=f90b12d41c277335d08c9dab62433f27c0fadbe5
>> They are a bit more thorough.
> Those new functions seem to have a lot of overlap with the code that is
> already upstream in p2pdma.... Perhaps you should be improving the
> p2pdma functions if they aren't suitable for what you want already
> instead of creating new ones.

Yeah, well that's what I was suggesting for the very beginning :)

But completely agree the existing functions should be improved instead 
of adding new ones,
Christian.

>
> Logan
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel

