Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 570C5C3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 08:39:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EB5C20874
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 08:39:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="ZVQN0C0X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EB5C20874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97FF16B0548; Mon, 26 Aug 2019 04:39:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 954FC6B0549; Mon, 26 Aug 2019 04:39:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 844A96B054A; Mon, 26 Aug 2019 04:39:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0185.hostedemail.com [216.40.44.185])
	by kanga.kvack.org (Postfix) with ESMTP id 645206B0548
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 04:39:55 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id CD096824CA1F
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 08:39:54 +0000 (UTC)
X-FDA: 75863931108.22.veil62_7386302a6c055
X-HE-Tag: veil62_7386302a6c055
X-Filterd-Recvd-Size: 5643
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net [5.45.199.163])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 08:39:53 +0000 (UTC)
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 3B9232E045B;
	Mon, 26 Aug 2019 11:39:51 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id kPAtGJAWjF-doPiv6Rx;
	Mon, 26 Aug 2019 11:39:51 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1566808791; bh=Y7ejts7lpiJhlX4+egWDk+iu4dJWOZ7po0kKT0OpMC4=;
	h=In-Reply-To:References:Date:Message-ID:From:To:Subject;
	b=ZVQN0C0X7bfLpqONhnIcbXCciPSnf0ZQe87EOzqxF7ubpJcjvtoTJmY+Jof+wIqia
	 PEaE9w9ENQcqOpxatGvjD0TmDLw+9EItjqMz8obWXNyoLfUEk2Nq2/ckAr+NthoGs5
	 cCPwE+ZAbNG9qfRqLLqgDRWz23KdHvzmNr8zZToU=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:f558:a2a9:365e:6e19])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id n5aJDOHkZi-doBieEVh;
	Mon, 26 Aug 2019 11:39:50 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH 00/14] per memcg lru_lock
To: Daniel Jordan <daniel.m.jordan@oracle.com>,
 Alex Shi <alex.shi@linux.alibaba.com>, cgroups@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
 Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <6ba1ffb0-fce0-c590-c373-7cbc516dbebd@oracle.com>
 <348495d2-b558-fdfd-a411-89c75d4a9c78@linux.alibaba.com>
 <b776032e-eabb-64ff-8aee-acc2b3711717@oracle.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <d5256ebf-8314-8c24-a7ed-e170b7d39b61@yandex-team.ru>
Date: Mon, 26 Aug 2019 11:39:49 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <b776032e-eabb-64ff-8aee-acc2b3711717@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22/08/2019 18.20, Daniel Jordan wrote:
> On 8/22/19 7:56 AM, Alex Shi wrote:
>> =E5=9C=A8 2019/8/22 =E4=B8=8A=E5=8D=882:00, Daniel Jordan =E5=86=99=E9=
=81=93:
>>> =C2=A0=C2=A0 https://git.kernel.org/pub/scm/linux/kernel/git/wfg/vm-s=
calability.git/tree/case-lru-file-readtwice>
>>> It's also synthetic but it stresses lru_lock more than just anon allo=
c/free.=C2=A0 It hits the page activate path, which is where we see this=20
>>> lock in our database, and if enough memory is configured lru_lock als=
o gets stressed during reclaim, similar to [1].
>>
>> Thanks for the sharing, this patchset can not help the [1] case, since=
 it's just relief the per container lock contention now.
>=20
> I should've been clearer.=C2=A0 [1] is meant as an example of someone s=
uffering from lru_lock during reclaim.=C2=A0 Wouldn't your series help=20
> per-memcg reclaim?
>=20
>> Yes, readtwice case could be more sensitive for this lru_lock changes =
in containers. I may try to use it in container with some tuning.=20
>> But anyway, aim9 is also pretty good to show the problem and solutions=
. :)
>>>
>>> It'd be better though, as Michal suggests, to use the real workload t=
hat's causing problems.=C2=A0 Where are you seeing contention?
>>
>> We repeatly create or delete a lot of different containers according t=
o servers load/usage, so normal workload could cause lots of pages=20
>> alloc/remove.=20
>=20
> I think numbers from that scenario would help your case.
>=20
>> aim9 could reflect part of scenarios. I don't know the DB scenario yet=
.
>=20
> We see it during DB shutdown when each DB process frees its memory (zap=
_pte_range -> mark_page_accessed).=C2=A0 But that's a different thing,=20
> clearly Not This Series.
>=20
>>>> With this patch series, lruvec->lru_lock show no contentions
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 &(&lruvec->lr=
u_l...=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 8=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0
>>>>
>>>> and aim9 page_test/brk_test performance increased 5%~50%.
>>>
>>> Where does the 50% number come in?=C2=A0 The numbers below seem to on=
ly show ~4% boost.
>>After splitting lru-locks present per-cpu page-vectors works no so well
because they mixes pages from different cgroups.

pagevec_lru_move_fn and friends need better implementation:
either sorting pages or splitting vectores in per-lruvec basis.
>> the Setddev/CoeffVar case has about 50% performance increase. one of c=
ontainer's mmtests result as following:
>>
>> Stddev=C2=A0=C2=A0=C2=A0 page_test=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 245.1=
5 (=C2=A0=C2=A0 0.00%)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 189.29 (=C2=A0 22.79=
%)
>> Stddev=C2=A0=C2=A0=C2=A0 brk_test=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1258.6=
0 (=C2=A0=C2=A0 0.00%)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 629.16 (=C2=A0 50.01=
%)
>> CoeffVar=C2=A0 page_test=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0.7=
1 (=C2=A0=C2=A0 0.00%)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0.53 (=C2=
=A0 26.05%)
>> CoeffVar=C2=A0 brk_test=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 1.32 (=C2=A0=C2=A0 0.00%)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0.64=
 (=C2=A0 51.14%)
>=20
> Aha.=C2=A0 50% decrease in stdev.
>=20

After splitting lru-locks present per-cpu page-vectors works
no so well because they mix pages from different cgroups.

pagevec_lru_move_fn and friends need better implementation:
either sorting pages or splitting vectores in per-lruvec basis.

