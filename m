Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E742C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:21:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B3F42067B
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:21:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B3F42067B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6B4F6B0007; Mon,  9 Sep 2019 08:21:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1BC76B0008; Mon,  9 Sep 2019 08:21:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0AE26B000A; Mon,  9 Sep 2019 08:21:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id 837F46B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:21:13 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 27864180AD801
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:21:13 +0000 (UTC)
X-FDA: 75915292026.03.spot38_61e345a00695f
X-HE-Tag: spot38_61e345a00695f
X-Filterd-Recvd-Size: 3215
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:21:12 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5AC8DAF38;
	Mon,  9 Sep 2019 12:21:11 +0000 (UTC)
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
 <b45eb4d9-b1ed-8637-84fa-2435ac285dde@suse.cz>
 <3ca34a49-6327-e6fd-2754-9b0700d87785@profihost.ag>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ec45c3f9-5649-fb39-ecf8-6ca7620a6e2a@suse.cz>
Date: Mon, 9 Sep 2019 14:21:10 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <3ca34a49-6327-e6fd-2754-9b0700d87785@profihost.ag>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/9/19 2:09 PM, Stefan Priebe - Profihost AG wrote:
>=20
> Am 09.09.19 um 13:49 schrieb Vlastimil Babka:
>> On 9/9/19 10:54 AM, Stefan Priebe - Profihost AG wrote:
>>>> Do you have more snapshots of /proc/vmstat as suggested by Vlastimil=
 and
>>>> me earlier in this thread? Seeing the overall progress would tell us
>>>> much more than before and after. Or have I missed this data?
>>>
>>> I needed to wait until today to grab again such a situation but from
>>> what i know it is very clear that MemFree is low and than the kernel
>>> starts to drop the chaches.
>>>
>>> Attached you'll find two log files.
>>
>> Thanks, what about my other requests/suggestions from earlier?
>=20
> Sorry i missed your email.
>=20
>> 1. How does /proc/pagetypeinfo look like?
>=20
> # cat /proc/pagetypeinfo
> Page block order: 9
> Pages per block:  512

Looks like it might be fragmented, but was that snapshot taken in the=20
situation where there's free memory and the system still drops cache?

>> 2. Could you also try if the bad trend stops after you execute:
>>  =C2=A0echo never > /sys/kernel/mm/transparent_hugepage/defrag
>> and report the result?
>=20
> it's pretty difficult to catch those moments. Is it OK so set the value
> now and monitor if it happens again?

Well if it doesn't happen again after changing that setting, it would=20
definitely point at THP interactions.

> Just to let you know:
> I've now also some more servers where memfree show 10-20Gb but cache
> drops suddently and memory PSI raises.

You mean those are in that state right now? So how does=20
/proc/pagetypeinfo look there, and would changing the defrag setting help=
?

> Greets,
> Stefan
>=20


