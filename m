Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF99CC28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 08:30:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74B0C24A5C
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 08:30:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74B0C24A5C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F0766B0266; Tue,  4 Jun 2019 04:30:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A2076B0269; Tue,  4 Jun 2019 04:30:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E83C36B026B; Tue,  4 Jun 2019 04:30:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACA776B0266
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 04:30:40 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d7so15596312pfq.15
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 01:30:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=e2CrbSdU+28IznNWnGxWp4oz+tpkIpAfbqJnZRJJGsI=;
        b=kvlnRQf/GZDjkOSWsLw9dBW55T5TAWzoyDXpO5RnqsRtqStlEEqfVJFr/vKlu8Xu+G
         jhjnrHcusSX4pxM99Hej6M2ZNRaDE31yPRcBWmRFQCOUGNQZhx9Tbp4EsZ8ZsuOZu2KP
         OGByHYuoaOTIsugitcDjpms+VljebtLa7GFVx+0VJulZYmQ8e63XBc1zBqcSdh2HF2SZ
         ZjzHXM6Po8n3IUC1FMR+Io6d9VrsXfKiSeJtB1KITYCgK0JODKpyxDjl8Z9aaX/Kwctc
         mDBXDieBZ5euV3g3CM0F0368rv+PyzAcgdKqX27QSLPa4stpn3DZXouwXb9ByCLvTuv+
         ZXRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVRUtKDr097QTbIDb4jDAO3rbSqibFLtFsqZsF7ZaJf6zGHIJyF
	34jPAhUcvW9tukXhAgctgJYxx2hbPhZczgxjRlcQN7xMWkF/Kaw8FXvJ0NJtyWVzsCuzEgZTwFG
	SN6py/cYh+WjBeJNrfZ3Ht/QggJWvHjG6E9QZxL01CFMHCeEdUohguh3UCCNX3vS5aw==
X-Received: by 2002:a63:dc09:: with SMTP id s9mr34308351pgg.425.1559637040359;
        Tue, 04 Jun 2019 01:30:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj2lTwZqOImpf02HZHE5mAswNdJ3TAdWTgoKSUrVeFXHisTotU7KYap0dFlm5evUIGbAfh
X-Received: by 2002:a63:dc09:: with SMTP id s9mr34308292pgg.425.1559637039503;
        Tue, 04 Jun 2019 01:30:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559637039; cv=none;
        d=google.com; s=arc-20160816;
        b=qRk6imT2ih7DVBT0i8dSvlN9Z/LMwUBNuUQr+aeRSbcUlcTFZO7TtrMaQi/rHS6DUW
         elAI6uTiOARfdAKw36OGHSwSiJz7QipoeEYGiPfF7Skx/kf4ypJgo7tnx8KXZop2vU8Y
         fq38ENJPXC5h7Kn2nsrtP0mAORKAvGEe5LYrep6l5uyJnoSQ+WP2I+7la/3EnWtvawIk
         ISBUMp/JGw5cDM8oTs+6mI3F5rylvtrzO3kWPhLQqwsYrqEpz81z7YlFDCf0WFpDusMh
         29ZMFxf8qBsFlxTrQfeEutryhNhUqvjrLgbzNcHnFjmfsRz+6gGxWJjQyEc67zVLgPq5
         Y/Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=e2CrbSdU+28IznNWnGxWp4oz+tpkIpAfbqJnZRJJGsI=;
        b=s8j7LC7TetRHanXdr/1D1jiOCCbYloMM1NllJbhNjkiA55LtaE+WP2ciZjL/DpP9vY
         c9xCHfTXQOvQJHN2VAfGEonhHUKqrcaULN541BWXcTrfJs4jcjeBviYbwVLnK/hnMD2a
         /uq/n48BP7iIDl4J7cfBOvg+ytqi+oLKtRUazAdwkW7y1ybXo2U6U2kZSb45cNSqR9tE
         ypggJJRyPY45UG06+UMaQatbe+2whqpv1FEPF/q/zGcNRiDZPIa7jWJHPT12khfe6bFt
         WlqpEIoL6uNMaWDghHpX1d66sNuomLWqGra8qFwPbFAM38tWyY8X2BGmAkWwzkcEs25P
         W+rA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m14si20583961pgj.377.2019.06.04.01.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 01:30:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x548MZkS126722
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 04:30:38 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2swhuugvvf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:30:38 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 4 Jun 2019 09:30:37 +0100
Received: from b03cxnp08028.gho.boulder.ibm.com (9.17.130.20)
	by e36.co.us.ibm.com (192.168.1.136) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 4 Jun 2019 09:30:34 +0100
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x548UXQM32637338
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 4 Jun 2019 08:30:33 GMT
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 86C816E04C;
	Tue,  4 Jun 2019 08:30:33 +0000 (GMT)
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9BC076E04E;
	Tue,  4 Jun 2019 08:30:30 +0000 (GMT)
Received: from [9.124.35.234] (unknown [9.124.35.234])
	by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue,  4 Jun 2019 08:30:30 +0000 (GMT)
Subject: Re: [PATCH] mm/gup: remove unnecessary check against CMA in
 __gup_longterm_locked()
To: Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Ira Weiny
 <ira.weiny@intel.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Mike Rapoport <rppt@linux.ibm.com>, John Hubbard <jhubbard@nvidia.com>,
        Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org
References: <1559633160-14809-1-git-send-email-kernelfans@gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Tue, 4 Jun 2019 14:00:29 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <1559633160-14809-1-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19060408-0020-0000-0000-00000EF3EFEC
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011212; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01213022; UDB=6.00637519; IPR=6.00994090;
 MB=3.00027177; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-04 08:30:37
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060408-0021-0000-0000-000066163871
Message-Id: <bb4fe1fe-dde0-b86b-740a-4b3dfa81d6f0@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=915 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040057
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/4/19 12:56 PM, Pingfan Liu wrote:
> The PF_MEMALLOC_NOCMA is set by memalloc_nocma_save(), which is finally
> cast to ~_GFP_MOVABLE.  So __get_user_pages_locked() will get pages from
> non CMA area and pin them.  There is no need to
> check_and_migrate_cma_pages().


That is not completely correct. We can fault in that pages outside 
get_user_pages_longterm at which point those pages can get allocated 
from CMA region. memalloc_nocma_save() as added as an optimization to 
avoid unnecessary page migration.


-aneesh

