Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3172C3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 07:28:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48ECB206E0
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 07:28:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Ilju32GZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48ECB206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E05256B04DC; Sat, 24 Aug 2019 03:28:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8D776B04DD; Sat, 24 Aug 2019 03:28:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C557F6B04DE; Sat, 24 Aug 2019 03:28:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0157.hostedemail.com [216.40.44.157])
	by kanga.kvack.org (Postfix) with ESMTP id 9E69B6B04DC
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 03:28:09 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 407E6824CA3D
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 07:28:09 +0000 (UTC)
X-FDA: 75856492698.24.cats96_643d695d75b21
X-HE-Tag: cats96_643d695d75b21
X-Filterd-Recvd-Size: 4892
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 07:28:08 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7O79jwe056487;
	Sat, 24 Aug 2019 07:27:40 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=mjq9fGw/Hlu3tLUadkrZ7NggHzDl6+rHr1rrLruw8us=;
 b=Ilju32GZjRTvskRFshNjOiuBhCDV2zbgDlgGHvE2MqzcQcYsl71fGWXoj5iQzppsKLOn
 qR/EBy6bOEe1mgx9RkBuXOF3MkHgBcEGxWcsmCkm28DAJl/vWc5/ZGD07PCwRnQuL79a
 ysrnAObTapR9HN7ev4e4yHBX7xcA7uzsGcJpg1S7UW4PxaAwx8AFfJgqqThlbltt3ibh
 sU0Pjcygcn6GXPkUJRbxzBeNfSYuElr5Nbicpr5zUSrMaG3AwA0AEiXQP1p1CTrO1Mue
 ouz9DTbJd1NVvMc8+w9lScFW8z8/r9Bfgaa4q2J3mlhTElt9UJSgd35Ab67B5v8Uq4WP JA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2ujw6yred3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 24 Aug 2019 07:27:40 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7O7O4LK032311;
	Sat, 24 Aug 2019 07:25:40 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2ujw6t445q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 24 Aug 2019 07:25:40 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x7O7PMi9019258;
	Sat, 24 Aug 2019 07:25:23 GMT
Received: from [192.168.43.36] (/172.58.30.166)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sat, 24 Aug 2019 00:25:22 -0700
Subject: Re: [RFC] mm: Proactive compaction
To: Vlastimil Babka <vbabka@suse.cz>, Nitin Gupta <nigupta@nvidia.com>,
        akpm@linux-foundation.org, mgorman@techsingularity.net,
        mhocko@suse.com, dan.j.williams@intel.com
Cc: Yu Zhao <yuzhao@google.com>, Matthew Wilcox <willy@infradead.org>,
        Qian Cai <cai@lca.pw>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Roman Gushchin <guro@fb.com>,
        Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
        Johannes Weiner <hannes@cmpxchg.org>, Arun KS <arunks@codeaurora.org>,
        Janne Huttunen <janne.huttunen@nokia.com>,
        Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190816214413.15006-1-nigupta@nvidia.com>
 <87634ddc-8bfd-8311-46c4-35f7dc32d42f@suse.cz>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <ca33d8ea-71a4-282e-4d0f-6d06a30d3ecd@oracle.com>
Date: Sat, 24 Aug 2019 01:24:50 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <87634ddc-8bfd-8311-46c4-35f7dc32d42f@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9358 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908240082
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9358 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908240080
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/20/19 2:46 AM, Vlastimil Babka wrote:
> +CC Khalid Aziz who proposed a different approach:
> https://lore.kernel.org/linux-mm/20190813014012.30232-1-khalid.aziz@ora=
cle.com/T/#u
>=20
> On 8/16/19 11:43 PM, Nitin Gupta wrote:
>> The patch has plenty of rough edges but posting it early to see if I'm=

>> going in the right direction and to get some early feedback.
>=20
> That's a lot of control knobs - how is an admin supposed to tune them t=
o their
> needs?
>=20

At a high level, this idea makes sense and is similar to the idea of
watermarks for free pages. My concern is the same. We now have more
knobs to tune and that increases complexity for sys admins as well as
the chances of a misconfigured system.

--
Khalid



