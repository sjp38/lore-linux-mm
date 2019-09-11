Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4401DECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 06:24:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10EAD21A4C
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 06:24:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10EAD21A4C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A709F6B0007; Wed, 11 Sep 2019 02:24:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A20806B0008; Wed, 11 Sep 2019 02:24:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 936186B000A; Wed, 11 Sep 2019 02:24:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0247.hostedemail.com [216.40.44.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD646B0007
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 02:24:28 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2145E181AC9C9
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 06:24:28 +0000 (UTC)
X-FDA: 75921650616.03.magic32_9d2c88629959
X-HE-Tag: magic32_9d2c88629959
X-Filterd-Recvd-Size: 4092
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de [178.250.10.56])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 06:24:27 +0000 (UTC)
Received: (qmail 9504 invoked from network); 11 Sep 2019 08:24:25 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.11.11.182]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Wed, 11 Sep 2019 08:24:25 +0200
Subject: Re: lot of MemAvailable but falling cache and raising PSI
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
 cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
 Vlastimil Babka <vbabka@suse.cz>
References: <52235eda-ffe2-721c-7ad7-575048e2d29d@profihost.ag>
 <20190910082919.GL2063@dhcp22.suse.cz>
 <132e1fd0-c392-c158-8f3a-20e340e542f0@profihost.ag>
 <20190910090241.GM2063@dhcp22.suse.cz>
 <743a047e-a46f-32fa-1fe4-a9bd8f09ed87@profihost.ag>
 <20190910110741.GR2063@dhcp22.suse.cz>
 <364d4c2e-9c9a-d8b3-43a8-aa17cccae9c7@profihost.ag>
 <20190910125756.GB2063@dhcp22.suse.cz>
 <d7448f13-899a-5805-bd36-8922fa17b8a9@profihost.ag>
 <b1fe902f-fce6-1aa9-f371-ceffdad85968@profihost.ag>
 <20190910132418.GC2063@dhcp22.suse.cz>
 <d07620d9-4967-40fe-fa0f-be51f2459dc5@profihost.ag>
Message-ID: <5f960e74-1f44-9a0a-58a6-dcb64aa71612@profihost.ag>
Date: Wed, 11 Sep 2019 08:24:25 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <d07620d9-4967-40fe-fa0f-be51f2459dc5@profihost.ag>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michal,

Am 11.09.19 um 08:12 schrieb Stefan Priebe - Profihost AG:
> Hi Michal,
> Am 10.09.19 um 15:24 schrieb Michal Hocko:
>> On Tue 10-09-19 15:14:45, Stefan Priebe - Profihost AG wrote:
>>> Am 10.09.19 um 15:05 schrieb Stefan Priebe - Profihost AG:
>>>>
>>>> Am 10.09.19 um 14:57 schrieb Michal Hocko:
>>>>> On Tue 10-09-19 14:45:37, Stefan Priebe - Profihost AG wrote:
>>>>>> Hello Michal,
>>>>>>
>>>>>> ok this might take a long time. Attached you'll find a graph from a
>>>>>> fresh boot what happens over time (here 17 August to 30 August). Memory
>>>>>> Usage decreases as well as cache but slowly and only over time and days.
>>>>>>
>>>>>> So it might take 2-3 weeks running Kernel 5.3 to see what happens.
>>>>>
>>>>> No problem. Just make sure to collect the requested data from the time
>>>>> you see the actual problem. Btw. you try my very dumb scriplets to get
>>>>> an idea of how much memory gets reclaimed due to THP.
>>>>
>>>> You mean your sed and sort on top of the trace file? No i did not with
>>>> the current 5.3 kernel do you think it will show anything interesting?
>>>> Which line shows me how much memory gets reclaimed due to THP?
>>
>> Please re-read http://lkml.kernel.org/r/20190910082919.GL2063@dhcp22.suse.cz
>> Each command has a commented output. If you see nunmber of reclaimed
>> pages to be large for GFP_TRANSHUGE then you are seeing a similar
>> problem.
>>
>>> Is something like a kernel memory leak possible? Or wouldn't this end up
>>> in having a lot of free memory which doesn't seem usable.
>>
>> I would be really surprised if this was the case.
>>
>>> I also wonder why a reclaim takes place when there is enough memory.
>>
>> This is not clear yet and it might be a bug that has been fixed since
>> 4.18. That's why we need to see whether the same is pattern is happening
>> with 5.3 as well.

but except from the btrfs problem the memory consumption looks far
better than before.

Running 4.19.X:
after about 12h cache starts to drop from 30G to 24G

Running 5.3-rc8:
after about 24h cache is still constant at nearly 30G

Greets,
Stefan

