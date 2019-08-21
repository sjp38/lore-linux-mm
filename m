Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75809C3A5A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 04:07:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F7EE2332A
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 04:07:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="d8Q/64LQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F7EE2332A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D112A6B028D; Wed, 21 Aug 2019 00:07:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC25B6B028E; Wed, 21 Aug 2019 00:07:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFF336B028F; Wed, 21 Aug 2019 00:07:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0118.hostedemail.com [216.40.44.118])
	by kanga.kvack.org (Postfix) with ESMTP id A22306B028D
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:07:23 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0E3D987CC
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 04:07:23 +0000 (UTC)
X-FDA: 75845100366.22.badge68_4066fccd5c533
X-HE-Tag: badge68_4066fccd5c533
X-Filterd-Recvd-Size: 3345
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 04:07:22 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5cc3790000>; Tue, 20 Aug 2019 21:07:22 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 20 Aug 2019 21:07:21 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 20 Aug 2019 21:07:21 -0700
Received: from DRHQMAIL107.nvidia.com (10.27.9.16) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 21 Aug
 2019 04:07:20 +0000
Received: from [10.2.161.11] (172.20.13.39) by DRHQMAIL107.nvidia.com
 (10.27.9.16) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 21 Aug
 2019 04:07:20 +0000
Subject: disregard: [PATCH 1/4] checkpatch: revert broken NOTIFIER_HEAD check
To: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, Andy Whitcroft <apw@canonical.com>, Joe Perches
	<joe@perches.com>, Gilad Ben-Yossef <gilad@benyossef.com>, Ofir Drang
	<ofir.drang@arm.com>
References: <20190821040355.19566-1-jhubbard@nvidia.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <7148f0a6-ee20-7c89-e11b-8ffe3053430b@nvidia.com>
Date: Tue, 20 Aug 2019 21:05:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190821040355.19566-1-jhubbard@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 DRHQMAIL107.nvidia.com (10.27.9.16)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566360442; bh=U6dFw5Ws7lt4i7y6B6eLJLXyO1E1XavUXw1yA0J+5V0=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=d8Q/64LQQmKuu3Q/qqnYCaLIetEHHMn3CaRH8dQ+Dqtbyg3M2by6NErdaqlxzy9S3
	 kb36YXBNUxf9kos4quc3VXSjz164OkNdfXhdyRA7zI0AsY31k1iC6v7pjxaW5GnRmF
	 Qu3bihEc9KQZTRDK8FxQcpuhg+lzkLVUIk8C2oBCklzVIatxXjgWe7Xe/Sb4fVfkDp
	 58QDCDYHT//I3TKAyic8P/sPKF9KVZRRfglG21DXObEiHYpQeUuibUs8GW0haa/87m
	 1YAfOryUurxDfIocVUNq87rgMdYBeJsXkPxtHZcohRu1S3Ip2m29yWb8sEi9Fw0TnP
	 BpZ4aPPEzaH3A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/20/19 9:03 PM, John Hubbard wrote:
> commit 1a47005dd5aa ("checkpatch: add *_NOTIFIER_HEAD as var
> definition") causes the following warning when run on some
> patches:
> 

Please disregard this series. It's stale.

thanks,
-- 
John Hubbard
NVIDIA

