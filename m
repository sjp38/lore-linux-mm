Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13239C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:46:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C52B120665
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:46:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="CVuR2nj1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C52B120665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AB066B0003; Wed, 14 Aug 2019 12:46:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45BF66B0005; Wed, 14 Aug 2019 12:46:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3231F6B0006; Wed, 14 Aug 2019 12:46:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0115.hostedemail.com [216.40.44.115])
	by kanga.kvack.org (Postfix) with ESMTP id 11D466B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:46:56 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C0BD32C33
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:46:55 +0000 (UTC)
X-FDA: 75821612790.23.shake00_1f53d2e9d5d32
X-HE-Tag: shake00_1f53d2e9d5d32
X-Filterd-Recvd-Size: 5358
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:46:55 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7EGXxbX021344;
	Wed, 14 Aug 2019 16:46:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=VvhFfIQodEPqTncWoL+pgUbxVYn0zik2m+SUHnaOaRk=;
 b=CVuR2nj1znokxokzca7kxC7LTFRrxvOO7LH8BUN8vLI42e1FMfZ2cQJAvXUNjuJw4uRx
 saCDS7omnO8zKhSczlZZBGkSwiUM3PKkwyEsd+ChuCf7SGj7lpbbTm4/btjKF1Pxefrd
 N17nqTpow9dnh2JPnNYyO9GrHV2990WOuLFlOsgrCGDBYkwoFqB8+Pyl5G4AEPXnJg46
 mhCy/rMuXR3q16SjJK4ChQGYC11RPAa+xMQqfqLlZPxOML+ovqLTMCgJ4zgWG3Txf1Kp
 viQJcYQ42+F299tgL84yWge1Eo9Vk0RzLLOWK9gXWq//2ZW7d966Hl9QDnrlyiDXbfkr Fg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2u9nbtp35u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 14 Aug 2019 16:46:50 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7EGXkNK186130;
	Wed, 14 Aug 2019 16:46:50 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2ubwcy8qv0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 14 Aug 2019 16:46:49 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x7EGknbG013123;
	Wed, 14 Aug 2019 16:46:49 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 14 Aug 2019 09:46:48 -0700
Subject: Re: [RFC PATCH v2 4/5] hugetlb_cgroup: Add accounting for shared
 mappings
From: Mike Kravetz <mike.kravetz@oracle.com>
To: Mina Almasry <almasrymina@google.com>
Cc: shuah@kernel.org, rientjes@google.com, shakeelb@google.com,
        gthelen@google.com, akpm@linux-foundation.org, khalid.aziz@oracle.com,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-kselftest@vger.kernel.org
References: <20190808231340.53601-1-almasrymina@google.com>
 <20190808231340.53601-5-almasrymina@google.com>
 <47cfc50d-bea3-0247-247e-888d2942f134@oracle.com>
Message-ID: <9872cec9-a0fe-cfe0-0df6-90b6dd909f04@oracle.com>
Date: Wed, 14 Aug 2019 09:46:47 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <47cfc50d-bea3-0247-247e-888d2942f134@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9349 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908140157
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9349 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908140157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/13/19 4:54 PM, Mike Kravetz wrote:
> On 8/8/19 4:13 PM, Mina Almasry wrote:
>> For shared mappings, the pointer to the hugetlb_cgroup to uncharge lives
>> in the resv_map entries, in file_region->reservation_counter.
>>
>> When a file_region entry is added to the resv_map via region_add, we
>> also charge the appropriate hugetlb_cgroup and put the pointer to that
>> in file_region->reservation_counter. This is slightly delicate since we
>> need to not modify the resv_map until we know that charging the
>> reservation has succeeded. If charging doesn't succeed, we report the
>> error to the caller, so that the kernel fails the reservation.
> 
> I wish we did not need to modify these region_() routines as they are
> already difficult to understand.  However, I see no other way with the
> desired semantics.
> 

I suspect you have considered this, but what about using the return value
from region_chg() in hugetlb_reserve_pages() to charge reservation limits?
There is a VERY SMALL race where the value could be too large, but that
can be checked and adjusted at region_add time as is done with normal
accounting today.  If the question is, where would we store the information
to uncharge?, then we can hang a structure off the vma.  This would be
similar to what is done for private mappings.  In fact, I would suggest
making them both use a new cgroup reserve structure hanging off the vma.

One issue I see is what to do if a vma is split?  The private mapping case
'should' handle this today, but I would not be surprised if such code is
missing or incorrect.

-- 
Mike Kravetz

