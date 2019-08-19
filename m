Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C684C3A59B
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 07:31:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A7252086C
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 07:31:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A7252086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F4376B000E; Mon, 19 Aug 2019 03:31:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A54E6B0010; Mon, 19 Aug 2019 03:31:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E2756B0266; Mon, 19 Aug 2019 03:31:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0179.hostedemail.com [216.40.44.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9716B000E
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 03:31:32 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D43C0181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 07:31:31 +0000 (UTC)
X-FDA: 75838357182.28.peace11_81bc52fe9b95f
X-HE-Tag: peace11_81bc52fe9b95f
X-Filterd-Recvd-Size: 1619
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 07:31:31 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CD5C2AF7C;
	Mon, 19 Aug 2019 07:31:29 +0000 (UTC)
Date: Mon, 19 Aug 2019 09:31:28 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Roman Gushchin <guro@fb.com>, Randy Dunlap <rdunlap@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] mm, memcg: skip killing processes under memcg protection
 at first scan
Message-ID: <20190819073128.GB3111@dhcp22.suse.cz>
References: <1566102294-14803-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566102294-14803-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 18-08-19 00:24:54, Yafang Shao wrote:
> In the current memory.min design, the system is going to do OOM instead
> of reclaiming the reclaimable pages protected by memory.min if the
> system is lack of free memory. While under this condition, the OOM
> killer may kill the processes in the memcg protected by memory.min.

Could you be more specific about the configuration that leads to this
situation?
-- 
Michal Hocko
SUSE Labs

