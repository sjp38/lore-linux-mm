Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18917C3A5AB
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 11:40:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E96B221848
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 11:40:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E96B221848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F84F6B0290; Thu,  5 Sep 2019 07:40:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A7D36B0292; Thu,  5 Sep 2019 07:40:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BCCA6B0293; Thu,  5 Sep 2019 07:40:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 45D2C6B0290
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 07:40:25 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E19DA82437C9
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:40:24 +0000 (UTC)
X-FDA: 75900673968.13.gold48_5ae390929cf55
X-HE-Tag: gold48_5ae390929cf55
X-Filterd-Recvd-Size: 1744
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:40:24 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 329E9AF05;
	Thu,  5 Sep 2019 11:40:23 +0000 (UTC)
Date: Thu, 5 Sep 2019 13:40:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: lot of MemAvailable but falling cache and raising PSI
Message-ID: <20190905114022.GH3838@dhcp22.suse.cz>
References: <4b4ba042-3741-7b16-2292-198c569da2aa@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b4ba042-3741-7b16-2292-198c569da2aa@profihost.ag>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 05-09-19 13:27:10, Stefan Priebe - Profihost AG wrote:
> Hello all,
> 
> i hope you can help me again to understand the current MemAvailable
> value in the linux kernel. I'm running a 4.19.52 kernel + psi patches in
> this case.
> 
> I'm seeing the following behaviour i don't understand and ask for help.
> 
> While MemAvailable shows 5G the kernel starts to drop cache from 4G down
> to 1G while the apache spawns some PHP processes. After that the PSI
> mem.some value rises and the kernel tries to reclaim memory but
> MemAvailable stays at 5G.
> 
> Any ideas?

Can you collect /proc/vmstat (every second or so) and post it while this
is the case please?
-- 
Michal Hocko
SUSE Labs

