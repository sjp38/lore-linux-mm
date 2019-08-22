Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83571C3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 20:12:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FC3D21848
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 20:12:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FC3D21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B24B6B0355; Thu, 22 Aug 2019 16:12:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 061356B0357; Thu, 22 Aug 2019 16:12:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB8126B0358; Thu, 22 Aug 2019 16:12:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0071.hostedemail.com [216.40.44.71])
	by kanga.kvack.org (Postfix) with ESMTP id C68EB6B0355
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 16:12:04 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 315B262D5
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 20:12:04 +0000 (UTC)
X-FDA: 75851160168.22.bomb92_69556da46e917
X-HE-Tag: bomb92_69556da46e917
X-Filterd-Recvd-Size: 1753
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 20:12:03 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BC096AE86;
	Thu, 22 Aug 2019 20:12:01 +0000 (UTC)
Date: Thu, 22 Aug 2019 22:12:00 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yizhuo Zhai <yzhai003@ucr.edu>
Cc: Chengyu Song <csong@cs.ucr.edu>, Zhiyun Qian <zhiyunq@cs.ucr.edu>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/memcg: return value of the function
 mem_cgroup_from_css() is not checked
Message-ID: <20190822201200.GP12785@dhcp22.suse.cz>
References: <20190822062210.18649-1-yzhai003@ucr.edu>
 <20190822070550.GA12785@dhcp22.suse.cz>
 <CABvMjLRCt4gC3GKzBehGppxfyMOb6OGQwW-6Yu_+MbMp5tN3tg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABvMjLRCt4gC3GKzBehGppxfyMOb6OGQwW-6Yu_+MbMp5tN3tg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000283, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 22-08-19 13:07:17, Yizhuo Zhai wrote:
> This will happen if variable "wb->memcg_css" is NULL. This case is reported
> by our analysis tool.

Does your tool report the particular call path and conditions when that
happen? Or is it just a "it mignt happen" kinda thing?

> Since the function mem_cgroup_wb_domain() is visible to the global, we
> cannot control caller's behavior.

I am sorry but I do not understand what is this supposed to mean.
-- 
Michal Hocko
SUSE Labs

