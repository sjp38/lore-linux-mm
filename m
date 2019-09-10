Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3E36C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 12:58:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CAFE20863
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 12:58:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CAFE20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 173416B0006; Tue, 10 Sep 2019 08:58:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 123906B0007; Tue, 10 Sep 2019 08:58:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A6A6B0008; Tue, 10 Sep 2019 08:58:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0116.hostedemail.com [216.40.44.116])
	by kanga.kvack.org (Postfix) with ESMTP id D7D496B0006
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:58:00 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7F965824376D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:58:00 +0000 (UTC)
X-FDA: 75919013520.01.quill56_28c4f36aebc35
X-HE-Tag: quill56_28c4f36aebc35
X-Filterd-Recvd-Size: 2113
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:58:00 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6A8F8B863;
	Tue, 10 Sep 2019 12:57:58 +0000 (UTC)
Date: Tue, 10 Sep 2019 14:57:56 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: lot of MemAvailable but falling cache and raising PSI
Message-ID: <20190910125756.GB2063@dhcp22.suse.cz>
References: <2d04fc69-8fac-2900-013b-7377ca5fd9a8@profihost.ag>
 <20190909124950.GN27159@dhcp22.suse.cz>
 <10fa0b97-631d-f82b-0881-89adb9ad5ded@profihost.ag>
 <52235eda-ffe2-721c-7ad7-575048e2d29d@profihost.ag>
 <20190910082919.GL2063@dhcp22.suse.cz>
 <132e1fd0-c392-c158-8f3a-20e340e542f0@profihost.ag>
 <20190910090241.GM2063@dhcp22.suse.cz>
 <743a047e-a46f-32fa-1fe4-a9bd8f09ed87@profihost.ag>
 <20190910110741.GR2063@dhcp22.suse.cz>
 <364d4c2e-9c9a-d8b3-43a8-aa17cccae9c7@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <364d4c2e-9c9a-d8b3-43a8-aa17cccae9c7@profihost.ag>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 10-09-19 14:45:37, Stefan Priebe - Profihost AG wrote:
> Hello Michal,
> 
> ok this might take a long time. Attached you'll find a graph from a
> fresh boot what happens over time (here 17 August to 30 August). Memory
> Usage decreases as well as cache but slowly and only over time and days.
> 
> So it might take 2-3 weeks running Kernel 5.3 to see what happens.

No problem. Just make sure to collect the requested data from the time
you see the actual problem. Btw. you try my very dumb scriplets to get
an idea of how much memory gets reclaimed due to THP.
-- 
Michal Hocko
SUSE Labs

