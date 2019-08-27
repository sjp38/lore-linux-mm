Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66997C3A5A6
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 13:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4165522CBB
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 13:53:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4165522CBB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C47C66B000D; Tue, 27 Aug 2019 09:53:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF89D6B000E; Tue, 27 Aug 2019 09:53:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B34FC6B0010; Tue, 27 Aug 2019 09:53:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0099.hostedemail.com [216.40.44.99])
	by kanga.kvack.org (Postfix) with ESMTP id 914B06B000D
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 09:53:25 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4328463FA
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 13:53:25 +0000 (UTC)
X-FDA: 75868349970.06.lunch97_b65ae455c06
X-HE-Tag: lunch97_b65ae455c06
X-Filterd-Recvd-Size: 2046
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 13:53:24 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5F707AC45;
	Tue, 27 Aug 2019 13:53:23 +0000 (UTC)
Date: Tue, 27 Aug 2019 15:53:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Yafang Shao <laoar.shao@gmail.com>,
	Adric Blake <promarbler14@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Subject: Re: WARNINGs in set_task_reclaim_state with memory
 cgroupandfullmemory usage
Message-ID: <20190827135322.GG7538@dhcp22.suse.cz>
References: <20190824130516.2540-1-hdanton@sina.com>
 <CALOAHbAuY9BnpX6x4KSNURbzybjn5UdSNL7-1Li3R0HSQBqiGQ@mail.gmail.com>
 <20190827132931.848986B0008@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827132931.848986B0008@kanga.kvack.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 21:29:24, Hillf Danton wrote:
> 
> >> No preference seems in either way except for retaining
> >> nr_to_reclaim == SWAP_CLUSTER_MAX and target_mem_cgroup == memcg.
> >
> > Setting  target_mem_cgroup here may be a very subtle change for
> > subsequent processing.
> > Regarding retraining nr_to_reclaim == SWAP_CLUSTER_MAX, it may not
> > proper for direct reclaim, that may cause some stall if we iterate all
> > memcgs here.
> 
> Mind posting a RFC to collect thoughts?

I hope I have explained why this is not desirable
http://lkml.kernel.org/r/20190827120335.GA7538@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

