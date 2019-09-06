Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DA41C43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:15:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9154206BB
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:15:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9154206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 797D16B0003; Fri,  6 Sep 2019 09:15:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 721346B0006; Fri,  6 Sep 2019 09:15:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E7D56B0007; Fri,  6 Sep 2019 09:15:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0139.hostedemail.com [216.40.44.139])
	by kanga.kvack.org (Postfix) with ESMTP id 37DE46B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 09:15:12 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 157F9180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:15:11 +0000 (UTC)
X-FDA: 75904541622.04.nut30_6754a315b0650
X-HE-Tag: nut30_6754a315b0650
X-Filterd-Recvd-Size: 1849
Received: from shards.monkeyblade.net (shards.monkeyblade.net [23.128.96.9])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:15:09 +0000 (UTC)
Received: from localhost (unknown [88.214.184.128])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 78D8F152F5C9A;
	Fri,  6 Sep 2019 06:15:06 -0700 (PDT)
Date: Fri, 06 Sep 2019 15:15:05 +0200 (CEST)
Message-Id: <20190906.151505.1486178691190611604.davem@davemloft.net>
To: jasowang@redhat.com
Cc: jgg@mellanox.com, mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, aarcange@redhat.com, jglisse@redhat.com,
 linux-mm@kvack.org
Subject: Re: [PATCH 0/2] Revert and rework on the metadata accelreation
From: David Miller <davem@davemloft.net>
In-Reply-To: <7785d39b-b4e7-8165-516c-ee6a08ac9c4e@redhat.com>
References: <20190905122736.19768-1-jasowang@redhat.com>
	<20190905135907.GB6011@mellanox.com>
	<7785d39b-b4e7-8165-516c-ee6a08ac9c4e@redhat.com>
X-Mailer: Mew version 6.8 on Emacs 26.2
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Fri, 06 Sep 2019 06:15:08 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 6 Sep 2019 18:02:35 +0800

> On 2019/9/5 下午9:59, Jason Gunthorpe wrote:
>> I think you should apply the revert this cycle and rebase the other
>> patch for next..
>>
>> Jason
> 
> Yes, the plan is to revert in this release cycle.

Then you should reset patch #1 all by itself targetting 'net'.

