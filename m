Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C21DC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 05:41:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 301F621928
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 05:41:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 301F621928
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE2926B0003; Tue, 10 Sep 2019 01:41:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B934E6B0006; Tue, 10 Sep 2019 01:41:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA77D6B0007; Tue, 10 Sep 2019 01:41:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id 82E366B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:41:28 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 356E1180AD7C3
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:41:28 +0000 (UTC)
X-FDA: 75917913456.19.son19_cbd037878221
X-HE-Tag: son19_cbd037878221
X-Filterd-Recvd-Size: 3289
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de [178.250.10.56])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:41:27 +0000 (UTC)
Received: (qmail 17945 invoked from network); 10 Sep 2019 07:41:25 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.11.11.182]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Tue, 10 Sep 2019 07:41:25 +0200
Subject: Re: lot of MemAvailable but falling cache and raising PSI
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
 cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
 Vlastimil Babka <vbabka@suse.cz>
References: <20190905114022.GH3838@dhcp22.suse.cz>
 <7a3d23f2-b5fe-b4c0-41cd-e79070637bd9@profihost.ag>
 <e866c481-04f2-fdb4-4d99-e7be2414591e@profihost.ag>
 <20190909082732.GC27159@dhcp22.suse.cz>
 <1d9ee19a-98c9-cd78-1e5b-21d9d6e36792@profihost.ag>
 <20190909110136.GG27159@dhcp22.suse.cz>
 <20190909120811.GL27159@dhcp22.suse.cz>
 <88ff0310-b9ab-36b6-d8ab-b6edd484d973@profihost.ag>
 <20190909122852.GM27159@dhcp22.suse.cz>
 <2d04fc69-8fac-2900-013b-7377ca5fd9a8@profihost.ag>
 <20190909124950.GN27159@dhcp22.suse.cz>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <7529b709-2085-e403-4a46-67071e3a328d@profihost.ag>
Date: Tue, 10 Sep 2019 07:41:25 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190909124950.GN27159@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Am 09.09.19 um 14:49 schrieb Michal Hocko:
> On Mon 09-09-19 14:37:52, Stefan Priebe - Profihost AG wrote:
>>
>> Am 09.09.19 um 14:28 schrieb Michal Hocko:
>>> On Mon 09-09-19 14:10:02, Stefan Priebe - Profihost AG wrote:
>>>>
>>>> Am 09.09.19 um 14:08 schrieb Michal Hocko:
>>>>> On Mon 09-09-19 13:01:36, Michal Hocko wrote:
>>>>>> and that matches moments when we reclaimed memory. There seems to be a
>>>>>> steady THP allocations flow so maybe this is a source of the direct
>>>>>> reclaim?
>>>>>
>>>>> I was thinking about this some more and THP being a source of reclaim
>>>>> sounds quite unlikely. At least in a default configuration because we
>>>>> shouldn't do anything expensinve in the #PF path. But there might be a
>>>>> difference source of high order (!costly) allocations. Could you check
>>>>> how many allocation requests like that you have on your system?

I've another system which might be interesting. Not sure which stuff to
gather.

It never builds up any read cache cause memory is constantly under
pressure. But memfree is 28G.

What would be interesting to collect here? Pressure is not very high
just 1-3% but it seems it prevents the system from building up file
cache. Mostly at the night where no pressure is it starts building up a
read cache until pressure happens again. But all this happens with
MemFree at nearly 30GB of memory.

Greets,
Stefan

