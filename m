Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7595CC3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 08:01:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10D6421883
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 08:01:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10D6421883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 710BB6B0005; Tue, 27 Aug 2019 04:01:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E8BD6B0006; Tue, 27 Aug 2019 04:01:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 600666B0007; Tue, 27 Aug 2019 04:01:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0062.hostedemail.com [216.40.44.62])
	by kanga.kvack.org (Postfix) with ESMTP id 404286B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 04:01:00 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id EA91A824CA2F
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 08:00:59 +0000 (UTC)
X-FDA: 75867461838.12.talk32_7d01ecd40041f
X-HE-Tag: talk32_7d01ecd40041f
X-Filterd-Recvd-Size: 1558
Received: from r3-25.sinamail.sina.com.cn (r3-25.sinamail.sina.com.cn [202.108.3.25])
	by imf02.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 08:00:58 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([124.64.0.77])
	by sina.com with ESMTP
	id 5D64E336000144AC; Tue, 27 Aug 2019 16:00:56 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 32347354981174
From: Hillf Danton <hdanton@sina.com>
To: Mina Almasry <almasrymina@google.com>,
	mike.kravetz@oracle.com
Cc: shuah@kernel.org,
	rientjes@google.com,
	shakeelb@google.com,
	gthelen@google.com,
	akpm@linux-foundation.org,
	khalid.aziz@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kselftest@vger.kernel.org,
	cgroups@vger.kernel.org,
	aneesh.kumar@linux.vnet.ibm.com,
	mkoutny@suse.com,
	Hillf Danton <hdanton@sina.com>
Subject: Re: [PATCH v3 1/6] hugetlb_cgroup: Add hugetlb_cgroup reservation counter
Date: Tue, 27 Aug 2019 16:00:45 +0800
Message-Id: <20190827080045.13532-1-hdanton@sina.com>
In-Reply-To: <20190826233240.11524-1-almasrymina@google.com>
References: <20190826233240.11524-1-almasrymina@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000011, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 26 Aug 2019 16:32:35 -0700 Mina Almasry wrote:
>
> These counters will track hugetlb reservations rather than hugetlb
> memory faulted in. This patch only adds the counter, following patches
> add the charging and uncharging of the counter.

Acked-by: Hillf Danton <hdanton@sina.com>


