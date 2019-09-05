Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB6EAC3A5A9
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 02:05:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 945402168B
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 02:05:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 945402168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 169F96B0006; Wed,  4 Sep 2019 22:05:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11B6F6B0007; Wed,  4 Sep 2019 22:05:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02EF96B0008; Wed,  4 Sep 2019 22:05:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0196.hostedemail.com [216.40.44.196])
	by kanga.kvack.org (Postfix) with ESMTP id D11B66B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 22:05:13 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 75E982C96
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 02:05:13 +0000 (UTC)
X-FDA: 75899224506.15.bird33_10557a7573c2f
X-HE-Tag: bird33_10557a7573c2f
X-Filterd-Recvd-Size: 2905
Received: from huawei.com (szxga05-in.huawei.com [45.249.212.191])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 02:05:12 +0000 (UTC)
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id C90804BEDD822EA701C6;
	Thu,  5 Sep 2019 10:05:07 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.439.0; Thu, 5 Sep 2019
 10:05:04 +0800
Message-ID: <5D706D50.3090305@huawei.com>
Date: Thu, 5 Sep 2019 10:05:04 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Vlastimil Babka <vbabka@suse.cz>
CC: <akpm@linux-foundation.org>, <mhocko@kernel.org>,
	<anshuman.khandual@arm.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Ira Weiny <ira.weiny@intel.com>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
References: <1567592763-25282-1-git-send-email-zhongjiang@huawei.com> <5505fa16-117e-8890-0f48-38555a61a036@suse.cz>
In-Reply-To: <5505fa16-117e-8890-0f48-38555a61a036@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/9/4 19:24, Vlastimil Babka wrote:
> On 9/4/19 12:26 PM, zhong jiang wrote:
>> With the help of unsigned_lesser_than_zero.cocci. Unsigned 'nr_pages"'
>> compare with zero. And __get_user_pages_locked will return an long val=
ue.
>> Hence, Convert the long to compare with zero is feasible.
> It would be nicer if the parameter nr_pages was long again instead of u=
nsigned
> long (note there are two variants of the function, so both should be ch=
anged).
Yep, the parameter 'nr_pages' was changed to long. and the variants =E2=80=
=98i=E3=80=81step=E2=80=99 should
be changed accordingly.
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> Fixes: 932f4a630a69 ("mm/gup: replace get_user_pages_longterm() with FO=
LL_LONGTERM")
>
> (which changed long to unsigned long)
>
> AFAICS... stable shouldn't be needed as the only "risk" is that we goto
> check_again even when we fail, which should be harmless.
Agreed, Thanks.

Sincerely,
zhong jiang
> Vlastimil
>
>> ---
>>  mm/gup.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/gup.c b/mm/gup.c
>> index 23a9f9c..956d5a1 100644
>> --- a/mm/gup.c
>> +++ b/mm/gup.c
>> @@ -1508,7 +1508,7 @@ static long check_and_migrate_cma_pages(struct t=
ask_struct *tsk,
>>  						   pages, vmas, NULL,
>>  						   gup_flags);
>> =20
>> -		if ((nr_pages > 0) && migrate_allow) {
>> +		if (((long)nr_pages > 0) && migrate_allow) {
>>  			drain_allow =3D true;
>>  			goto check_again;
>>  		}
>>
>
> .
>



