Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30FB8C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 07:07:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0750E206A5
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 07:07:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0750E206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 932236B0007; Tue, 10 Sep 2019 03:07:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BA6E6B0008; Tue, 10 Sep 2019 03:07:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A9386B000A; Tue, 10 Sep 2019 03:07:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0121.hostedemail.com [216.40.44.121])
	by kanga.kvack.org (Postfix) with ESMTP id 52F736B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 03:07:23 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id EEC148243763
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:07:22 +0000 (UTC)
X-FDA: 75918129924.18.paste84_234de69514508
X-HE-Tag: paste84_234de69514508
X-Filterd-Recvd-Size: 1878
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:07:22 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 15D7AB621;
	Tue, 10 Sep 2019 07:07:21 +0000 (UTC)
Date: Tue, 10 Sep 2019 09:07:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: git.cmpxchg.org/linux-mmots.git repository corruption?
Message-ID: <20190910070720.GF2063@dhcp22.suse.cz>
References: <1568037544.5576.119.camel@lca.pw>
 <1568062593.5576.123.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1568062593.5576.123.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000049, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 09-09-19 16:56:33, Qian Cai wrote:
> On Mon, 2019-09-09 at 09:59 -0400, Qian Cai wrote:
> > Tried a few times without luck. Anyone else has the same issue?
> > 
> > # git clone git://git.cmpxchg.org/linux-mmots.git
> > Cloning into 'linux-mmots'...
> > remote: Enumerating objects: 7838808, done.
> > remote: Counting objects: 100% (7838808/7838808), done.
> > remote: Compressing objects: 100% (1065702/1065702), done.
> > remote: aborting due to possible repository corruption on the remote side.
> > fatal: early EOF
> > fatal: index-pack failed
> 
> It seems that it is just the remote server is too slow. Does anyone consider
> moving it to a more popular place like git.kernel.org or github etc?

Andrew was considering about a git tree for mm patches earlier this
year. But I am not sure it materialized in something. Andrew? poke poke
;)
-- 
Michal Hocko
SUSE Labs

