Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADE7CC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:49:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85F4A21924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:49:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F4A21924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D1266B0005; Mon,  9 Sep 2019 07:49:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8836B000A; Mon,  9 Sep 2019 07:49:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BEDB6B000C; Mon,  9 Sep 2019 07:49:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0181.hostedemail.com [216.40.44.181])
	by kanga.kvack.org (Postfix) with ESMTP id ED8A56B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:49:46 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 888EA6D8A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:49:46 +0000 (UTC)
X-FDA: 75915212772.10.color69_72617256c144f
X-HE-Tag: color69_72617256c144f
X-Filterd-Recvd-Size: 2175
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:49:45 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5EF4CAD44;
	Mon,  9 Sep 2019 11:49:44 +0000 (UTC)
Subject: Re: lot of MemAvailable but falling cache and raising PSI
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
 Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
 cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
References: <4b4ba042-3741-7b16-2292-198c569da2aa@profihost.ag>
 <20190905114022.GH3838@dhcp22.suse.cz>
 <7a3d23f2-b5fe-b4c0-41cd-e79070637bd9@profihost.ag>
 <e866c481-04f2-fdb4-4d99-e7be2414591e@profihost.ag>
 <20190909082732.GC27159@dhcp22.suse.cz>
 <1d9ee19a-98c9-cd78-1e5b-21d9d6e36792@profihost.ag>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b45eb4d9-b1ed-8637-84fa-2435ac285dde@suse.cz>
Date: Mon, 9 Sep 2019 13:49:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1d9ee19a-98c9-cd78-1e5b-21d9d6e36792@profihost.ag>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/9/19 10:54 AM, Stefan Priebe - Profihost AG wrote:
>> Do you have more snapshots of /proc/vmstat as suggested by Vlastimil and
>> me earlier in this thread? Seeing the overall progress would tell us
>> much more than before and after. Or have I missed this data?
> 
> I needed to wait until today to grab again such a situation but from
> what i know it is very clear that MemFree is low and than the kernel
> starts to drop the chaches.
> 
> Attached you'll find two log files.

Thanks, what about my other requests/suggestions from earlier?

1. How does /proc/pagetypeinfo look like?
2. Could you also try if the bad trend stops after you execute:
  echo never > /sys/kernel/mm/transparent_hugepage/defrag
and report the result?

Thanks

