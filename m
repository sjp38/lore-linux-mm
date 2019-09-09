Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FFBFC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:31:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ECB520692
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:31:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ECB520692
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B7026B0007; Mon,  9 Sep 2019 08:31:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93FB56B0008; Mon,  9 Sep 2019 08:31:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E8916B000A; Mon,  9 Sep 2019 08:31:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0107.hostedemail.com [216.40.44.107])
	by kanga.kvack.org (Postfix) with ESMTP id 571B66B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:31:07 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E6835181AC9B4
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:31:06 +0000 (UTC)
X-FDA: 75915316932.19.cats97_26b98fe297812
X-HE-Tag: cats97_26b98fe297812
X-Filterd-Recvd-Size: 6182
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de [178.250.10.56])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:31:05 +0000 (UTC)
Received: (qmail 964 invoked from network); 9 Sep 2019 14:31:04 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.11.11.182]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Mon, 09 Sep 2019 14:31:04 +0200
Subject: Re: lot of MemAvailable but falling cache and raising PSI
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
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
 <ec45c3f9-5649-fb39-ecf8-6ca7620a6e2a@suse.cz>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <79e3af38-0b85-51aa-1737-078fab076a87@profihost.ag>
Date: Mon, 9 Sep 2019 14:31:04 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <ec45c3f9-5649-fb39-ecf8-6ca7620a6e2a@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am 09.09.19 um 14:21 schrieb Vlastimil Babka:
> On 9/9/19 2:09 PM, Stefan Priebe - Profihost AG wrote:
>>
>> Am 09.09.19 um 13:49 schrieb Vlastimil Babka:
>>> On 9/9/19 10:54 AM, Stefan Priebe - Profihost AG wrote:
>>>>> Do you have more snapshots of /proc/vmstat as suggested by
>>>>> Vlastimil and
>>>>> me earlier in this thread? Seeing the overall progress would tell u=
s
>>>>> much more than before and after. Or have I missed this data?
>>>>
>>>> I needed to wait until today to grab again such a situation but from
>>>> what i know it is very clear that MemFree is low and than the kernel
>>>> starts to drop the chaches.
>>>>
>>>> Attached you'll find two log files.
>>>
>>> Thanks, what about my other requests/suggestions from earlier?
>>
>> Sorry i missed your email.
>>
>>> 1. How does /proc/pagetypeinfo look like?
>>
>> # cat /proc/pagetypeinfo
>> Page block order: 9
>> Pages per block:=C2=A0 512
>=20
> Looks like it might be fragmented, but was that snapshot taken in the
> situation where there's free memory and the system still drops cache?

No this one is from "now" where no pressure is recorded and where mem
free is at 3G and cache is also at 3G.

>>> 2. Could you also try if the bad trend stops after you execute:
>>> =C2=A0=C2=A0echo never > /sys/kernel/mm/transparent_hugepage/defrag
>>> and report the result?
>>
>> it's pretty difficult to catch those moments. Is it OK so set the valu=
e
>> now and monitor if it happens again?
>=20
> Well if it doesn't happen again after changing that setting, it would
> definitely point at THP interactions.

OK i set it to never.

>> Just to let you know:
>> I've now also some more servers where memfree show 10-20Gb but cache
>> drops suddently and memory PSI raises.
>=20
> You mean those are in that state right now? So how does
> /proc/pagetypeinfo look there, and would changing the defrag setting he=
lp?

Yes i've a system which constantly triggers PSI (just 1-3%) but Mem Free
is at 29GB.

1402:
# cat /proc/pagetypeinfo
Page block order: 9
Pages per block:  512

Free pages count per migrate type at order       0      1      2      3
     4      5      6      7      8      9     10
Node    0, zone      DMA, type    Unmovable      0      0      0      1
     2      1      1      0      1      0      0
Node    0, zone      DMA, type      Movable      0      0      0      0
     0      0      0      0      0      1      3
Node    0, zone      DMA, type  Reclaimable      0      0      0      0
     0      0      0      0      0      0      0
Node    0, zone      DMA, type   HighAtomic      0      0      0      0
     0      0      0      0      0      0      0
Node    0, zone      DMA, type      Isolate      0      0      0      0
     0      0      0      0      0      0      0
Node    0, zone    DMA32, type    Unmovable      0      1      0      1
     0      1      0      1      1      0      3
Node    0, zone    DMA32, type      Movable     42     29     60     52
    56     52     47     46     24      3     48
Node    0, zone    DMA32, type  Reclaimable      0      0      3      1
     0      1      1      1      1      0      0
Node    0, zone    DMA32, type   HighAtomic      0      0      0      0
     0      0      0      0      0      0      0
Node    0, zone    DMA32, type      Isolate      0      0      0      0
     0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable    189   7690  24737  14314
  7620   5362   3458   1607    165      0      0
Node    0, zone   Normal, type      Movable  29269  31003  70251  73957
 54776  37134  21084  10547   2307     35      4
Node    0, zone   Normal, type  Reclaimable   1431   3837   1821   2137
  2475    978    386    112      2      0      0
Node    0, zone   Normal, type   HighAtomic      0      0      1      3
     3      3      1      0      1      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0
     0      0      0      0      0      0      0

Number of blocks type     Unmovable      Movable  Reclaimable
HighAtomic      Isolate
Node 0, zone      DMA            1            7            0
0            0
Node 0, zone    DMA32           10         1005            1
0            0
Node 0, zone   Normal         3407        27184         1152
1            0

Stefan

