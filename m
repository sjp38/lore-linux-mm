Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 964F3C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 08:27:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AAE020863
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 08:27:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AAE020863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB8396B0005; Mon,  9 Sep 2019 04:27:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C68CB6B0007; Mon,  9 Sep 2019 04:27:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7E666B0008; Mon,  9 Sep 2019 04:27:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0224.hostedemail.com [216.40.44.224])
	by kanga.kvack.org (Postfix) with ESMTP id 906606B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 04:27:35 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 40D42180AD802
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:27:35 +0000 (UTC)
X-FDA: 75914703270.28.sleep54_5f4f2d734d032
X-HE-Tag: sleep54_5f4f2d734d032
X-Filterd-Recvd-Size: 2045
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:27:34 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 30C9AB04C;
	Mon,  9 Sep 2019 08:27:33 +0000 (UTC)
Date: Mon, 9 Sep 2019 10:27:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: lot of MemAvailable but falling cache and raising PSI
Message-ID: <20190909082732.GC27159@dhcp22.suse.cz>
References: <4b4ba042-3741-7b16-2292-198c569da2aa@profihost.ag>
 <20190905114022.GH3838@dhcp22.suse.cz>
 <7a3d23f2-b5fe-b4c0-41cd-e79070637bd9@profihost.ag>
 <e866c481-04f2-fdb4-4d99-e7be2414591e@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e866c481-04f2-fdb4-4d99-e7be2414591e@profihost.ag>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 06-09-19 12:08:31, Stefan Priebe - Profihost AG wrote:
> These are the biggest differences in meminfo before and after cached
> starts to drop. I didn't expect cached end up in MemFree.
> 
> Before:
> MemTotal:       16423116 kB
> MemFree:          374572 kB
> MemAvailable:    5633816 kB
> Cached:          5550972 kB
> Inactive:        4696580 kB
> Inactive(file):  3624776 kB
> 
> 
> After:
> MemTotal:       16423116 kB
> MemFree:         3477168 kB
> MemAvailable:    6066916 kB
> Cached:          2724504 kB
> Inactive:        1854740 kB
> Inactive(file):   950680 kB
> 
> Any explanation?

Do you have more snapshots of /proc/vmstat as suggested by Vlastimil and
me earlier in this thread? Seeing the overall progress would tell us
much more than before and after. Or have I missed this data?

-- 
Michal Hocko
SUSE Labs

