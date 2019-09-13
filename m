Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C47D8C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:05:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87BED2089F
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:05:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="nh/E1Sqp";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="F+hZZpZz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87BED2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AD776B0005; Fri, 13 Sep 2019 05:05:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15E7B6B0006; Fri, 13 Sep 2019 05:05:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 075006B0007; Fri, 13 Sep 2019 05:05:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0176.hostedemail.com [216.40.44.176])
	by kanga.kvack.org (Postfix) with ESMTP id DAB126B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 05:05:48 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6EC55181AC9B4
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:05:48 +0000 (UTC)
X-FDA: 75929314776.12.rub69_4fbf9bbd71429
X-HE-Tag: rub69_4fbf9bbd71429
X-Filterd-Recvd-Size: 4168
Received: from smtp.codeaurora.org (smtp.codeaurora.org [198.145.29.96])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:05:47 +0000 (UTC)
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 891FD60721; Fri, 13 Sep 2019 09:05:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1568365546;
	bh=MKoCAvdRxWDK7nYJ8Y57zozHNj2ndMnytboaGeAfdvo=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=nh/E1SqpjoVGzNu2Gu7aX+0OVbuA/POmjjyzlurKE6BBUcSxOJDz1HTrR/rDVBThg
	 3IzRtWDILAG+LJ007T6Grv0b6VAbX+RSDWe7WN+TmjS94jatvgryHK5APYtuSSdklz
	 GLaT+cD/nS+npnjY8EdEyTRWq+xiT6UGW8jNgW9s=
Received: from [10.204.83.131] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: vinmenon@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 8A9AC6083E;
	Fri, 13 Sep 2019 09:05:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1568365545;
	bh=MKoCAvdRxWDK7nYJ8Y57zozHNj2ndMnytboaGeAfdvo=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=F+hZZpZz+0M3h4Ru8Yrk/EaWqFptXryImhCoV/wD/CmoqAPDKMh/v/ULft+3kg6J4
	 VR+Mt+sCnODwRRtxVzwC2VNg2z5+j431KhxKSo8rNgzTjMdFPansVM3E06Ex1ISO2H
	 YNxkT7Mu3A77qsHdKaYdvJXTZPe6017VlcQTatrQ=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 8A9AC6083E
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=vinmenon@codeaurora.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
 <20190909232613.GA39783@google.com>
 <9df3bb51-2094-c849-8171-dce6784e1e70@codeaurora.org>
 <20190910175116.GB39783@google.com>
 <c7fbc609-0bb0-bffd-8b1f-c2588c89bfd2@codeaurora.org>
 <20190912171400.GA119788@google.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <3a500b81-71bb-54bd-9f2f-ab89ee723879@codeaurora.org>
Date: Fri, 13 Sep 2019 14:35:41 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <20190912171400.GA119788@google.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 9/12/2019 10:44 PM, Minchan Kim wrote:
> Hi Vinayak,
>
> On Wed, Sep 11, 2019 at 03:37:23PM +0530, Vinayak Menon wrote:
>
> < snip >
>
>>>> Can swapcache check be done like below, before taking the SWP_SYNCHRONOUS_IO path, as an alternative ?
>>> With your approach, what prevent below scenario?
>>>
>>> A                                                       B
>>>
>>>                                             do_swap_page
>>>                                             SWP_SYNCHRONOUS_IO && __swap_count == 1
>>
>> As shrink_page_list is picking the page from LRU and B is trying to read from swap simultaneously, I assume someone had read
>>
>> the page from swap prior to B, when its swap_count was say 2 (for it to be reclaimed by shrink_page_list now)
> It could happen after B saw __swap_count == 1. Think about forking new process.
> In that case, swap_count is 2 and the forked process will access the page(it
> ends up freeing zram slot but the page would be swap cache. However, B process
> doesn't know it).


Okay, so when B has read __swap_count == 1, it means that it has taken down_read on mmap_sem in fault path

already. This means fork will not be able to proceed which needs to have down_write on parent's mmap_sem ?



