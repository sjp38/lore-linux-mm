Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EBF9C3A59E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:45:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 397162082F
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:45:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 397162082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEAA56B0007; Tue, 20 Aug 2019 06:45:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9A9B6B0008; Tue, 20 Aug 2019 06:45:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB1536B000A; Tue, 20 Aug 2019 06:45:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0119.hostedemail.com [216.40.44.119])
	by kanga.kvack.org (Postfix) with ESMTP id 98C506B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:45:35 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4B29B8138
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:45:35 +0000 (UTC)
X-FDA: 75842475030.10.cry54_880d2514c5938
X-HE-Tag: cry54_880d2514c5938
X-Filterd-Recvd-Size: 1893
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:45:34 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 69F2AADD9;
	Tue, 20 Aug 2019 10:45:33 +0000 (UTC)
Date: Tue, 20 Aug 2019 12:45:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alex Shi <alex.shi@linux.alibaba.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
	Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 00/14] per memcg lru_lock
Message-ID: <20190820104532.GP3111@dhcp22.suse.cz>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 20-08-19 17:48:23, Alex Shi wrote:
> This patchset move lru_lock into lruvec, give a lru_lock for each of
> lruvec, thus bring a lru_lock for each of memcg.
> 
> Per memcg lru_lock would ease the lru_lock contention a lot in
> this patch series.
> 
> In some data center, containers are used widely to deploy different kind
> of services, then multiple memcgs share per node pgdat->lru_lock which
> cause heavy lock contentions when doing lru operation.

Having some real world workloads numbers would be more than useful
for a non trivial change like this. I believe googlers have tried
something like this in the past but then didn't have really a good
example of workloads that benefit. I might misremember though. Cc Hugh.

-- 
Michal Hocko
SUSE Labs

