Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3939CC43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:49:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10B68206B8
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:49:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10B68206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4DA36B0006; Fri,  6 Sep 2019 09:49:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFE426B0007; Fri,  6 Sep 2019 09:49:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A14A36B0008; Fri,  6 Sep 2019 09:49:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0120.hostedemail.com [216.40.44.120])
	by kanga.kvack.org (Postfix) with ESMTP id 8008D6B0006
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 09:49:04 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2BCBE180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:49:04 +0000 (UTC)
X-FDA: 75904627008.26.color43_6c3cc77e4ec02
X-HE-Tag: color43_6c3cc77e4ec02
X-Filterd-Recvd-Size: 2211
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:49:03 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 685BAB034;
	Fri,  6 Sep 2019 13:49:02 +0000 (UTC)
Date: Fri, 6 Sep 2019 15:49:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Qian Cai <cai@lca.pw>, linux-mm@kvack.org
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
Message-ID: <20190906134901.GG14491@dhcp22.suse.cz>
References: <20190903144512.9374-1-mhocko@kernel.org>
 <1567522966.5576.51.camel@lca.pw>
 <20190903151307.GZ14028@dhcp22.suse.cz>
 <1567699853.5576.98.camel@lca.pw>
 <8ea5da51-a1ac-4450-17d9-0ea7be346765@i-love.sakura.ne.jp>
 <1567718475.5576.108.camel@lca.pw>
 <192f2cb9-172e-06f4-d9e4-a58b5e167231@i-love.sakura.ne.jp>
 <1567775335.5576.110.camel@lca.pw>
 <7eada349-90d0-a12f-701c-adac3c395e3c@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7eada349-90d0-a12f-701c-adac3c395e3c@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000031, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 06-09-19 22:41:39, Tetsuo Handa wrote:
> On 2019/09/06 22:08, Qian Cai wrote:
> > Yes, mlocked is troublesome. I have other incidents where crond and systemd-
> > udevd were killed by mistake,
> 
> Yes. How to mitigate this regression is a controversial topic.
> Michal thinks that we should make mlocked pages reclaimable, but
> we haven't reached there. I think that we can monitor whether
> counters decay over time (with timeout), but Michal refuses any
> timeout based approach. We are deadlocked there.

There is really nothing controversial here. It just needs somebody to do
the actual work. Besides that I haven't seen any real workload to mlock
so much memory that there won't be anything reapable. LTP oom test
simply doesn't represent any real world workload. So while not optimal
I do not really think this is something to lose sleep over.
-- 
Michal Hocko
SUSE Labs

