Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB94BC3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 15:21:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E73D233A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 15:21:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="TUTU2NnU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E73D233A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09ECF6B032C; Thu, 22 Aug 2019 11:21:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 028626B032D; Thu, 22 Aug 2019 11:21:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E32736B032E; Thu, 22 Aug 2019 11:21:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id C05D46B032C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:21:00 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 5C04F6D8F
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 15:21:00 +0000 (UTC)
X-FDA: 75850426680.14.rifle24_25c7eafac2d5f
X-HE-Tag: rifle24_25c7eafac2d5f
X-Filterd-Recvd-Size: 6059
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 15:20:59 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7MF4Mx0087310;
	Thu, 22 Aug 2019 15:20:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=1L5ER/qHk23OYtUxN07nDgRdnfnZxx2DF63Rw066TEU=;
 b=TUTU2NnUGOh4xD4o+ekU6weirf9jpHf+pLiY1Q/982QWFCZeo0muWZqUzEIst9mmeX2G
 tvc1KCLIMJv2FqopEsyv9HxiinVifeIFZCOgOXpieTlIyE8BeQT5DXBbUeH9BA0GC9f6
 SkWbP7KPLFpzj68lv1OfKaMVHRSLAvsoHzQarkWQyeeglWf6MzaDzBMcVo8CHqrA0PWn
 gC9SiP1VTgkabkM2NZBe6va8+EacRo3aq8PzjlZ90Q57mH9CIy9gYUV1DMDBTWHFVliT
 W7QWqT+hSJMIQ8GpYi/X7nlE+ViJU+0yCyasx6cEh9hTVifRdlge73HeEEwcgwfEymcU sA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2ue90txm3f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 22 Aug 2019 15:20:56 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7MF3xeU179464;
	Thu, 22 Aug 2019 15:20:56 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2uhusembk0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 22 Aug 2019 15:20:55 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7MFKrjU013736;
	Thu, 22 Aug 2019 15:20:54 GMT
Received: from [192.168.1.219] (/98.229.125.203)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 22 Aug 2019 15:20:53 +0000
Subject: Re: [PATCH 00/14] per memcg lru_lock
To: Alex Shi <alex.shi@linux.alibaba.com>, cgroups@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
        Michal Hocko <mhocko@kernel.org>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <6ba1ffb0-fce0-c590-c373-7cbc516dbebd@oracle.com>
 <348495d2-b558-fdfd-a411-89c75d4a9c78@linux.alibaba.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <b776032e-eabb-64ff-8aee-acc2b3711717@oracle.com>
Date: Thu, 22 Aug 2019 11:20:52 -0400
MIME-Version: 1.0
In-Reply-To: <348495d2-b558-fdfd-a411-89c75d4a9c78@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9356 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908220150
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9356 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908220150
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000031, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/22/19 7:56 AM, Alex Shi wrote:
> =E5=9C=A8 2019/8/22 =E4=B8=8A=E5=8D=882:00, Daniel Jordan =E5=86=99=E9=81=
=93:
>>  =C2=A0 https://git.kernel.org/pub/scm/linux/kernel/git/wfg/vm-scalabi=
lity.git/tree/case-lru-file-readtwice>
>> It's also synthetic but it stresses lru_lock more than just anon alloc=
/free.=C2=A0 It hits the page activate path, which is where we see this l=
ock in our database, and if enough memory is configured lru_lock also get=
s stressed during reclaim, similar to [1].
>=20
> Thanks for the sharing, this patchset can not help the [1] case, since =
it's just relief the per container lock contention now.

I should've been clearer.  [1] is meant as an example of someone sufferin=
g from lru_lock during reclaim.  Wouldn't your series help per-memcg recl=
aim?

> Yes, readtwice case could be more sensitive for this lru_lock changes i=
n containers. I may try to use it in container with some tuning. But anyw=
ay, aim9 is also pretty good to show the problem and solutions. :)
>>
>> It'd be better though, as Michal suggests, to use the real workload th=
at's causing problems.=C2=A0 Where are you seeing contention?
>=20
> We repeatly create or delete a lot of different containers according to=
 servers load/usage, so normal workload could cause lots of pages alloc/r=
emove.=20

I think numbers from that scenario would help your case.

> aim9 could reflect part of scenarios. I don't know the DB scenario yet.

We see it during DB shutdown when each DB process frees its memory (zap_p=
te_range -> mark_page_accessed).  But that's a different thing, clearly N=
ot This Series.

>>> With this patch series, lruvec->lru_lock show no contentions
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 &(&lruvec->lru_l...=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 8=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0
>>>
>>> and aim9 page_test/brk_test performance increased 5%~50%.
>>
>> Where does the 50% number come in?=C2=A0 The numbers below seem to onl=
y show ~4% boost.
>=20
> the Setddev/CoeffVar case has about 50% performance increase. one of co=
ntainer's mmtests result as following:
>=20
> Stddev    page_test      245.15 (   0.00%)      189.29 (  22.79%)
> Stddev    brk_test      1258.60 (   0.00%)      629.16 (  50.01%)
> CoeffVar  page_test        0.71 (   0.00%)        0.53 (  26.05%)
> CoeffVar  brk_test         1.32 (   0.00%)        0.64 (  51.14%)

Aha.  50% decrease in stdev.

