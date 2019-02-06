Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15BF2C282CB
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 02:10:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E7FF2184E
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 02:10:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="TA+NN3CT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E7FF2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 247418E009C; Tue,  5 Feb 2019 21:10:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F61D8E001C; Tue,  5 Feb 2019 21:10:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 099108E009C; Tue,  5 Feb 2019 21:10:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBA808E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 21:10:29 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id y133so3653873ywa.21
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 18:10:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=LrzDBXn7m4n3c90H00ykAOLq//WSnoIOgsc8KwJ6i7U=;
        b=t77Ud2iHRuOi5pJ4iBeXSipFvUhcxtSgkndfWmoguq8QXw93lSngAgS420mdaDmHhu
         lN6vPu2Kj4eDLFSMlzd0SzNoBMytVES1G1xzQTJEEJaRYHwbGugdsLMrOVzvx5uxp02X
         ubXSgSXryM8peZHWA/TvNfVPAiI7wsxXFY6YcMDlOU5CY5DKcSVAdIp3KeMA1Y9E8tWB
         017w4Lf8KaUYRni5QCkYTnkwsz4ZXPCK/8P2in/AAS32ZAy3Xx8GQSoLe5Q1lzeYOI4i
         YHXx2DZicjmD8Ob2FzNvnk9qDLVLniSHy6Q8bqUD+EuTs7u5FqyE8ssCcYKDJmoyYC1P
         btew==
X-Gm-Message-State: AHQUAualRilY/EAQW0IVL7ciZspdYwuIWSKfIqxA2aSfTPbi+yx7R/bf
	zhx/DQTc2nOTSIfP7gY6eCaRPxVDIG9RBsvG5OWFMQKTNkSbruKT7KLXNl7OI7NLC+h3hg48I73
	tex4Gf76F7hOWfZw+gO7fUtfh6iaOAayBuZ23XXbzcXtS1JM64eqcGHXTiHixwdZtxw==
X-Received: by 2002:a5b:903:: with SMTP id a3mr6723387ybq.445.1549419029490;
        Tue, 05 Feb 2019 18:10:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbOX0/pIhRN214mHA2v4hIX0+jHoHH0PDLEMD/T+U1UmdmyqqrWc2WXAOh1yX/Bo5iwNxYF
X-Received: by 2002:a5b:903:: with SMTP id a3mr6723350ybq.445.1549419028553;
        Tue, 05 Feb 2019 18:10:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549419028; cv=none;
        d=google.com; s=arc-20160816;
        b=wUsIBArMCt6wUunbSjxROUQLtf92NSFnnjJUwFjS0DKnatsEbOj9H1V6/lsjCkj94f
         9qpb/GvqadLNfDaKA8uiCgJnHw0gHOI3tAhStUyKDI10gHjEKm/ZR/bkDMyP6UabO01c
         wY153Q3azAxPkvcwzViZqjLQ3NP8ot2KjoD8BShU6wsdH6FWiDGge/iILcHmlc8qty0m
         IXh7VIV/8crMoutGf6mg699fiobp2AOn0vKPY437dCDP8LY9hDeCd4gV7hvIY0fcMXh6
         dSQ5XkWY/6QDfo1AGNYEs6e0PU86WWaduGmDfHf8vdXIlZvL91BiPugc3BShFZZ1m5vJ
         NZDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=LrzDBXn7m4n3c90H00ykAOLq//WSnoIOgsc8KwJ6i7U=;
        b=DARluLI2p9W0pOY5k/im299gFshOU+lsbfpLU4szJdjvkusVIrwzUI9huNoOpIc7wl
         gt3u0wLQf4+d7P7+2Fa/x3PK479yDHQPM7kpcB+bQF2ut9S/aP/CYXUFUjNFAyKQmU1y
         AkqSwvDBjSGDowKiWCJp+n7+AZ6QwZVp+BfzEbmpHTo4dQ7LMW4yUX0ScyAz5/LVBsZE
         3eJmc83a2oh5lAPoQQc08FLqQ4iKeuU+AlWDUAR+dtxpavvyzurvrcFBq1nrDdrCqhBA
         pNCQOJSeqnqXvrYJlFjb+OZzdE7HHJurE+SDcNjWCj5oXjSXDkwdHJtWpbTeJjbnjTob
         9sig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TA+NN3CT;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d125si2928575ybb.253.2019.02.05.18.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 18:10:28 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TA+NN3CT;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c5a41f40000>; Tue, 05 Feb 2019 18:09:56 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 05 Feb 2019 18:10:27 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 05 Feb 2019 18:10:27 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 6 Feb
 2019 02:10:27 +0000
Subject: Re: [LSF/MM TOPIC] get_user_pages() pins in file mappings
To: Jan Kara <jack@suse.cz>
CC: <lsf-pc@lists.linux-foundation.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse
	<jglisse@redhat.com>
References: <20190124090400.GE12184@quack2.suse.cz>
 <a0d37cc9-2d44-ac58-0dc0-c245a55082c3@nvidia.com>
 <20190205112107.GB3872@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <e16e3993-1400-c28d-f651-12d3f1129434@nvidia.com>
Date: Tue, 5 Feb 2019 18:10:26 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190205112107.GB3872@quack2.suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549418996; bh=LrzDBXn7m4n3c90H00ykAOLq//WSnoIOgsc8KwJ6i7U=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=TA+NN3CTnNO9SN7o2OwFhQ8mdZrTB4ecEhe1Iyk3QO5s3ttTXHEmwZncXerTwFnsW
	 y5YO1jAXocjNFAdLAXSMWL4gsdmt2ssTmIfTM1wUufECGWh3+VLa/hXWB8tT59zqQ+
	 qkgaVgk4rDNC7sU94mWAdfJmYgo+B4ywK63DdnMOo7TTgE6OaxQafM6NSyBNdR4taT
	 TgCoXbpZTYHQHLdFJ9PBbKb4j1e5e5Urh1qdMyTPCEpW9SB2/5atzEx9R+XgHVIp8c
	 R0n8oNjz7dDO5/6DOEF1QUKYvnUXC7d8JQpAErNjsOAZgrQ2VKv7cjgzfCbGDLEQ8x
	 giq4t9KPPm3/Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/5/19 3:21 AM, Jan Kara wrote:
> Hi John,
> 
> On Mon 04-02-19 15:46:10, John Hubbard wrote:
>> On 1/24/19 1:04 AM, Jan Kara wrote:
>>
>>> In particular we hope to have reasonably robust mechanism of identifying
>>> pages pinned by GUP (patches will be posted soon) - I'd like to run that by
>>> MM folks (unless discussion happens on mailing lists before LSF/MM). We
>>> also have ideas how filesystems should react to pinned page in their
>>> writepages methods - there will be some changes needed in some filesystems
>>> to bounce the page if they need stable page contents. So I'd like to
>>> explain why we chose to do bouncing to fs people (i.e., why we cannot just
>>> wait, skip the page, do something else etc.) to save us from the same
>>> discussion with each fs separately and also hash out what the API for
>>> filesystems to do this should look like. Finally we plan to keep pinned
>>> page permanently dirty - again something I'd like to explain why we do this
>>> and gather input from other people.
>>
>> Hi Jan,
>>
>> Say, I was just talking through this point with someone on our driver team, 
>> and suddenly realized that I'm now slightly confused on one point. If we end
>> up keeping the gup-pinned pages effectively permanently dirty while pinned,
>> then maybe the call sites no longer need to specify "dirty" (or not) when
>> they call put_user_page*()?
>>
>> In other words, the RFC [1] has this API:
>>
>>     void put_user_page(struct page *page);
>>     void put_user_pages_dirty(struct page **pages, unsigned long npages);
>>     void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
>>     void put_user_pages(struct page **pages, unsigned long npages);
>>
>> But maybe we only really need this:
>>
>>     void put_user_page(struct page *page);
>>     void put_user_pages(struct page **pages, unsigned long npages);
>>
>> ?
>>
>> [1] https://lkml.kernel.org/r/20190204052135.25784-1-jhubbard@nvidia.com
> 
> So you are right that if we keep gup-pinned pages dirty, drivers could get
> away without marking them as such. However I view "keep pages dirty" as an
> implementation detail, rather than a promise of the API. So I'd like to
> leave us the flexibility of choosing a different implementation in the
> future. And as such I'd just leave the put_user_pages_dirty() variants in
> place.
> 
> 								Honza

OK, sounds good. And after all, removing that information from the call sites 
is easy, but adding it back in would be hell, so leaving it in definitely
sounds better. I'm just looking for anything that says "this API isn't ready
yet", but I guess we're still OK there.


thanks,
-- 
John Hubbard
NVIDIA

