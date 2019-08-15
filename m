Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05A86C32753
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 02:58:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D7FD2084F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 02:58:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D7FD2084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06FBB6B0003; Wed, 14 Aug 2019 22:58:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 020226B0005; Wed, 14 Aug 2019 22:58:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E50FB6B0007; Wed, 14 Aug 2019 22:58:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0206.hostedemail.com [216.40.44.206])
	by kanga.kvack.org (Postfix) with ESMTP id C53316B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 22:58:54 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 559598248AA2
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 02:58:54 +0000 (UTC)
X-FDA: 75823154988.30.hook76_87ce7383beb62
X-HE-Tag: hook76_87ce7383beb62
X-Filterd-Recvd-Size: 1494
Received: from mail3-167.sinamail.sina.com.cn (mail3-167.sinamail.sina.com.cn [202.108.3.167])
	by imf48.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 02:58:52 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([221.219.6.224])
	by sina.com with ESMTP
	id 5D54CA6700009860; Thu, 15 Aug 2019 10:58:49 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 951025190362
From: Hillf Danton <hdanton@sina.com>
To: Mina Almasry <almasrymina@google.com>
Cc: mike.kravetz@oracle.com,
	shuah@kernel.org,
	rientjes@google.com,
	shakeelb@google.com,
	gthelen@google.com,
	akpm@linux-foundation.org,
	khalid.aziz@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kselftest@vger.kernel.org
Subject: Re: [RFC PATCH v2 0/5] hugetlb_cgroup: Add hugetlb_cgroup reservation limits
Date: Thu, 15 Aug 2019 10:58:37 +0800
Message-Id: <20190815025837.3044-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000086, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu,  8 Aug 2019 16:13:35 -0700 Mina Almasry wrote:
>=20
> Mina Almasry (5):
>   hugetlb_cgroup: Add hugetlb_cgroup reservation counter
>   hugetlb_cgroup: add interface for charge/uncharge hugetlb reservation=
s
>   hugetlb_cgroup: add reservation accounting for private mappings
>   hugetlb_cgroup: add accounting for shared mappings
>   hugetlb_cgroup: Add hugetlb_cgroup reservation tests

    hugetlb_cgroup: Add hugetlb_cgroup reservation doc words


