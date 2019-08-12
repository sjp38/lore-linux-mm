Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31E50C32756
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 04:13:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E46692075B
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 04:13:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E46692075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8999A6B0003; Mon, 12 Aug 2019 00:13:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84A1B6B0005; Mon, 12 Aug 2019 00:13:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75EF36B0006; Mon, 12 Aug 2019 00:13:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id 512956B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 00:13:46 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id ECF352659
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 04:13:45 +0000 (UTC)
X-FDA: 75812457210.05.name89_20d740624414e
X-HE-Tag: name89_20d740624414e
X-Filterd-Recvd-Size: 1960
Received: from shards.monkeyblade.net (shards.monkeyblade.net [23.128.96.9])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 04:13:45 +0000 (UTC)
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 02A2B144DC6C6;
	Sun, 11 Aug 2019 21:13:43 -0700 (PDT)
Date: Sun, 11 Aug 2019 21:13:43 -0700 (PDT)
Message-Id: <20190811.211343.1920857192153512765.davem@davemloft.net>
To: jasowang@redhat.com
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, jgg@ziepe.ca
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
From: David Miller <davem@davemloft.net>
In-Reply-To: <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
References: <20190809054851.20118-1-jasowang@redhat.com>
	<20190810134948-mutt-send-email-mst@kernel.org>
	<360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Sun, 11 Aug 2019 21:13:44 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 12 Aug 2019 10:44:51 +0800

> On 2019/8/11 上午1:52, Michael S. Tsirkin wrote:
>> At this point how about we revert
>> 7f466032dc9e5a61217f22ea34b2df932786bbfc
>> for this release, and then re-apply a corrected version
>> for the next one?
> 
> If possible, consider we've actually disabled the feature. How about
> just queued those patches for next release?

I'm tossing this series while you and Michael decide how to move forward.

