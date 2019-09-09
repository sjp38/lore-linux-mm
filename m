Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6465C49ED4
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 02:30:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B49812067B
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 02:30:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B49812067B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E9F16B0005; Sun,  8 Sep 2019 22:30:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 499D06B0006; Sun,  8 Sep 2019 22:30:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B09E6B0007; Sun,  8 Sep 2019 22:30:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0092.hostedemail.com [216.40.44.92])
	by kanga.kvack.org (Postfix) with ESMTP id 1960D6B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 22:30:57 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B16FC824CA3B
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 02:30:56 +0000 (UTC)
X-FDA: 75913804512.14.game25_254c1fcfcd81b
X-HE-Tag: game25_254c1fcfcd81b
X-Filterd-Recvd-Size: 2367
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 02:30:56 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 278F160ACF;
	Mon,  9 Sep 2019 02:30:55 +0000 (UTC)
Received: from [10.72.12.61] (ovpn-12-61.pek2.redhat.com [10.72.12.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7B5E560166;
	Mon,  9 Sep 2019 02:30:24 +0000 (UTC)
Subject: Re: [PATCH 2/2] vhost: re-introducing metadata acceleration through
 kernel virtual address
From: Jason Wang <jasowang@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, jgg@mellanox.com,
 aarcange@redhat.com, jglisse@redhat.com, linux-mm@kvack.org,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Christoph Hellwig <hch@infradead.org>, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
References: <20190905122736.19768-1-jasowang@redhat.com>
 <20190905122736.19768-3-jasowang@redhat.com>
 <20190908063618-mutt-send-email-mst@kernel.org>
 <1cb5aa8d-6213-5fce-5a77-fcada572c882@redhat.com>
Message-ID: <868bfaed-ede4-6da8-0247-af2a03ea121d@redhat.com>
Date: Mon, 9 Sep 2019 10:30:20 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1cb5aa8d-6213-5fce-5a77-fcada572c882@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 09 Sep 2019 02:30:55 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/9/9 =E4=B8=8A=E5=8D=8810:18, Jason Wang wrote:
>>>
>>> On a elder CPU Sandy Bridge without SMAP support. TX PPS doesn't see
>>> any difference.
>> Why is not Kaby Lake with SMAP off the same as Sandy Bridge?
>
>
> I don't know, I guess it was because the atomic is l=20


Sorry, I meant atomic costs less for Kaby Lake.

Thanks



