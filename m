Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57AABC49ED4
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 07:18:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24E6721920
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 07:18:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24E6721920
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DE9C6B000A; Mon,  9 Sep 2019 03:18:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98E7E6B000C; Mon,  9 Sep 2019 03:18:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CC4E6B000D; Mon,  9 Sep 2019 03:18:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0043.hostedemail.com [216.40.44.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0106B000A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 03:18:31 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0603087E6
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:18:31 +0000 (UTC)
X-FDA: 75914529222.10.limit85_4a50321746f4a
X-HE-Tag: limit85_4a50321746f4a
X-Filterd-Recvd-Size: 2457
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:18:30 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8386310576CC;
	Mon,  9 Sep 2019 07:18:29 +0000 (UTC)
Received: from [10.72.12.61] (ovpn-12-61.pek2.redhat.com [10.72.12.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A73161001948;
	Mon,  9 Sep 2019 07:18:06 +0000 (UTC)
Subject: Re: [PATCH 0/2] Revert and rework on the metadata accelreation
To: David Miller <davem@davemloft.net>
Cc: jgg@mellanox.com, mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, aarcange@redhat.com, jglisse@redhat.com,
 linux-mm@kvack.org
References: <20190905122736.19768-1-jasowang@redhat.com>
 <20190905135907.GB6011@mellanox.com>
 <7785d39b-b4e7-8165-516c-ee6a08ac9c4e@redhat.com>
 <20190906.151505.1486178691190611604.davem@davemloft.net>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <bb9ae371-58b7-b7fc-b728-b5c5f55d3a91@redhat.com>
Date: Mon, 9 Sep 2019 15:18:01 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190906.151505.1486178691190611604.davem@davemloft.net>
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.64]); Mon, 09 Sep 2019 07:18:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/9/6 下午9:15, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Fri, 6 Sep 2019 18:02:35 +0800
>
>> On 2019/9/5 下午9:59, Jason Gunthorpe wrote:
>>> I think you should apply the revert this cycle and rebase the other
>>> patch for next..
>>>
>>> Jason
>> Yes, the plan is to revert in this release cycle.
> Then you should reset patch #1 all by itself targetting 'net'.


Thanks for the reminding. I want the patch to go through Michael's vhost  
tree, that's why I don't put 'net' prefix. For next time, maybe I can  
use "vhost" as a prefix for classification?


