Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85AF4C3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 11:23:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 636112173E
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 11:23:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 636112173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC2CB6B0008; Wed, 28 Aug 2019 07:23:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4C746B000C; Wed, 28 Aug 2019 07:23:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3A706B000D; Wed, 28 Aug 2019 07:23:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0061.hostedemail.com [216.40.44.61])
	by kanga.kvack.org (Postfix) with ESMTP id AC4366B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:23:43 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 531D08243760
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 11:23:43 +0000 (UTC)
X-FDA: 75871601526.21.beast34_3d8d7d1ef863e
X-HE-Tag: beast34_3d8d7d1ef863e
X-Filterd-Recvd-Size: 1797
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 11:23:42 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 895E0AEE1;
	Wed, 28 Aug 2019 11:23:41 +0000 (UTC)
Date: Wed, 28 Aug 2019 13:23:40 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mina Almasry <almasrymina@google.com>
Cc: mike.kravetz@oracle.com, shuah@kernel.org, rientjes@google.com,
	shakeelb@google.com, gthelen@google.com, akpm@linux-foundation.org,
	khalid.aziz@oracle.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
	cgroups@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com,
	mkoutny@suse.com
Subject: Re: [PATCH v3 0/6] hugetlb_cgroup: Add hugetlb_cgroup reservation
 limits
Message-ID: <20190828112340.GB7466@dhcp22.suse.cz>
References: <20190826233240.11524-1-almasrymina@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826233240.11524-1-almasrymina@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 26-08-19 16:32:34, Mina Almasry wrote:
>  mm/hugetlb.c                                  | 493 ++++++++++++------
>  mm/hugetlb_cgroup.c                           | 187 +++++--

This is a lot of changes to an already subtle code which hugetlb
reservations undoubly are. Moreover cgroupv1 is feature frozen and I am
not aware of any plans to port the controller to v2. That all doesn't
sound in favor of this change. Mike is the maintainer of the hugetlb
code so I will defer to him to make a decision but I wouldn't recommend
that.
-- 
Michal Hocko
SUSE Labs

