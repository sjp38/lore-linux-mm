Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30F6AC3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 09:18:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD81C20828
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 09:18:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD81C20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CDD66B0005; Tue, 27 Aug 2019 05:18:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A5F06B0006; Tue, 27 Aug 2019 05:18:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 094866B0007; Tue, 27 Aug 2019 05:18:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0048.hostedemail.com [216.40.44.48])
	by kanga.kvack.org (Postfix) with ESMTP id DE8726B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 05:18:16 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 840B8180AD7C1
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 09:18:16 +0000 (UTC)
X-FDA: 75867656592.01.cave86_4816ba72d0234
X-HE-Tag: cave86_4816ba72d0234
X-Filterd-Recvd-Size: 1436
Received: from r3-18.sinamail.sina.com.cn (r3-18.sinamail.sina.com.cn [202.108.3.18])
	by imf20.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 09:18:15 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([124.64.0.77])
	by sina.com with ESMTP
	id 5D64F552000212D6; Tue, 27 Aug 2019 17:18:12 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 83094615128083
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
Subject: Re: [PATCH v3 6/6] hugetlb_cgroup: Add hugetlb_cgroup reservation docs
Date: Tue, 27 Aug 2019 17:18:02 +0800
Message-Id: <20190827091802.14048-1-hdanton@sina.com>
In-Reply-To: <20190826233240.11524-1-almasrymina@google.com>
References: <20190826233240.11524-1-almasrymina@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000117, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 26 Aug 2019 16:32:40 -0700 Mina Almasry wrote:
>
> Add docs for how to use hugetlb_cgroup reservations, and their behavior=
.

Acked-by: Hillf Danton <hdanton@sina.com>


