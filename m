Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40A92C47404
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 12:29:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F8AD20856
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 12:29:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F8AD20856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cn.fujitsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A08FD6B0005; Thu, 12 Sep 2019 08:29:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9916A6B0007; Thu, 12 Sep 2019 08:29:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 858BD6B0008; Thu, 12 Sep 2019 08:29:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0218.hostedemail.com [216.40.44.218])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2376B0005
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 08:29:46 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 007B41E081
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 12:29:45 +0000 (UTC)
X-FDA: 75926199972.24.death81_380c5ef6d0a04
X-HE-Tag: death81_380c5ef6d0a04
X-Filterd-Recvd-Size: 2338
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com [183.91.158.132])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 12:29:44 +0000 (UTC)
X-IronPort-AV: E=Sophos;i="5.64,495,1559491200"; 
   d="scan'208";a="75376775"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 12 Sep 2019 20:29:41 +0800
Received: from G08CNEXCHPEKD01.g08.fujitsu.local (unknown [10.167.33.80])
	by cn.fujitsu.com (Postfix) with ESMTP id B7DB44CE14ED;
	Thu, 12 Sep 2019 20:29:32 +0800 (CST)
Received: from [10.167.226.60] (10.167.226.60) by
 G08CNEXCHPEKD01.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.439.0; Thu, 12 Sep 2019 20:29:50 +0800
Subject: Re: [PATCH] mm/memblock: fix typo in memblock doc
To: Mike Rapoport <rppt@linux.ibm.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
References: <20190911030856.18010-1-caoj.fnst@cn.fujitsu.com>
 <20190911144230.GB6429@linux.ibm.com>
 <59f571f6-785c-7f6e-fd03-5cfc76da27be@cn.fujitsu.com>
 <20190912103535.GB9062@linux.ibm.com>
From: Cao jin <caoj.fnst@cn.fujitsu.com>
Message-ID: <8a9af872-3fb7-a438-a36a-8db6fb660afe@cn.fujitsu.com>
Date: Thu, 12 Sep 2019 20:29:47 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190912103535.GB9062@linux.ibm.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.167.226.60]
X-yoursite-MailScanner-ID: B7DB44CE14ED.AA08B
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: caoj.fnst@cn.fujitsu.com
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/12/19 6:35 PM, Mike Rapoport wrote:
> On Thu, Sep 12, 2019 at 10:54:09AM +0800, Cao jin wrote:
>> On 9/11/19 10:42 PM, Mike Rapoport wrote:

>>
>> Sure. BTW, do you want convert all the markups too?
>>
>>     :c:type:`foo` -> struct foo
>>     %FOO -> FOO
>>     ``foo`` -> foo
>>     **foo** -> foo
> 
> The documentation toolchain can recognize now foo() as a function and does
> not require the :c:func: prefix for that. AFAIK it only works for
> functions, so please don't change the rest of the markup.
>  

I see. Thanks for the info. Patch on the way.

-- 
Sincerely,
Cao jin



