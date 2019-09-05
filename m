Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97836C47401
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:16:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E3BE2082C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:08:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E3BE2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D1EF6B027B; Thu,  5 Sep 2019 10:08:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 982616B027D; Thu,  5 Sep 2019 10:08:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 879066B027F; Thu,  5 Sep 2019 10:08:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0194.hostedemail.com [216.40.44.194])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7716B027B
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:08:37 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0EACC180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:08:37 +0000 (UTC)
X-FDA: 75901047474.25.clam69_4b2dc08b93320
X-HE-Tag: clam69_4b2dc08b93320
X-Filterd-Recvd-Size: 1901
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:08:36 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3F3F5AD07;
	Thu,  5 Sep 2019 14:08:33 +0000 (UTC)
Date: Thu, 5 Sep 2019 16:08:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
Message-ID: <20190905140833.GB3838@dhcp22.suse.cz>
References: <20190903144512.9374-1-mhocko@kernel.org>
 <af0703d2-17e4-1b8e-eb54-58d7743cad60@i-love.sakura.ne.jp>
 <20190904054004.GA3838@dhcp22.suse.cz>
 <alpine.DEB.2.21.1909041302290.95127@chino.kir.corp.google.com>
 <12bcade2-4190-5e5e-35c6-7a04485d74b9@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12bcade2-4190-5e5e-35c6-7a04485d74b9@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 05-09-19 22:39:47, Tetsuo Handa wrote:
[...]
> There is nothing that prevents users from enabling oom_dump_tasks by sysctl.
> But that requires a solution for OOM stalling problem.

You can hardly remove stalling if you are not reducing the amount of
output or get it into a different context. Whether the later is
reasonable is another question but you are essentially losing "at the
OOM event state".

> Since I know how
> difficult to avoid problems caused by printk() flooding, I insist that
> we need "mm,oom: Defer dump_tasks() output." patch.

insisting is not a way to cooperate.
-- 
Michal Hocko
SUSE Labs

