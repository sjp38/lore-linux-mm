Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ECA0C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 02:57:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 361E521872
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 02:57:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 361E521872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B032C6B0010; Thu, 14 Mar 2019 22:57:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB2566B0266; Thu, 14 Mar 2019 22:57:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9528E6B0269; Thu, 14 Mar 2019 22:57:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 651F36B0010
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 22:57:57 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d49so7416289qtd.15
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 19:57:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=MVyI1nzjyZLc2etSwJmdxENyFL0872dP1+6QIuperfI=;
        b=RsImbKCVyV7nCI/N7yMy46u+M7uHxOkHtzKrVYPhk6ctSTNRqwfecTu8Mx1/dUqS6d
         uLQONrvTZfLDaEpOxKpcJ/r0g9xVHPem7q5M4H6NaA5SLhFTZmWq7abuBPs4jzcfwu+4
         FPmz/12v9MUj6okEWGgqFmoE8zJH6HwSj4ddPFi2NcrcG1Evp949fY3uX65U4ua7Pr9Q
         pC1qT2mfMiJQXpxT3ZaQVO1zkcSD6ZOyMqA/azKn/ZkYKkYduFntEJlqBnYMSwI6UurE
         WqMyoDLhwfoXH6zmlobG9N+mzj37AauOUmRcbJQHiB5ps4A0ioG5CCI491O47xCzOsmH
         tamA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWyEK1URGJc7xF8vnMK87ZW6S+T59NmADjswbIOKtoQbfrv3uk5
	u7iQbJdvkCT27q4yD6mVFDgpfIThLK1Ob8yzsPzs6KsMpLpPcU2MtYdTyzRwaklLCGV8eJGuOcC
	OHhS0yZHmdsbIL65VgnmmMhMFY3ahjelkNRZV5i92bLYmHukaC2zvI65Z3+nNxSqfoQ==
X-Received: by 2002:ac8:5286:: with SMTP id s6mr1093419qtn.118.1552618677132;
        Thu, 14 Mar 2019 19:57:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTBI7n4iyMTi0jDNt2T+CjTvNM5jc9ReFCvjLEhuiA9j6TjTSrLcfDiLbDtuudJKCVUw1x
X-Received: by 2002:ac8:5286:: with SMTP id s6mr1093391qtn.118.1552618676376;
        Thu, 14 Mar 2019 19:57:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552618676; cv=none;
        d=google.com; s=arc-20160816;
        b=sSsmqla093JICTT1NEH4JA700N8HLtbMbb1vNUTv08KgxqGe+m45rLJhkYaO9B+slj
         9n1PFDhewohaVosy24KDrfd6e0oPjKshckLBrbTwQT5ci92BnGupS8W4yMnhrcLjpsRm
         C1AsBvA7zv0xbVFHyApFHeaSXJOLZ/XPPGvR+z3JGURWW7GZI7iILmY907sKKzKB84x+
         xmfaw5QIow0wKqpZhQ3YBPdUHAcOjzVxB7Wz3N1VYhd2F+dLpEmMMXVNVXMAxxFVXphw
         55fnfrPpYd4MDLDVShaEbyPxKAjGPqwnOM6DAUVc5x8Sgd6XCXz6254buhJvAGtbBmD5
         NXTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:to:subject;
        bh=MVyI1nzjyZLc2etSwJmdxENyFL0872dP1+6QIuperfI=;
        b=KZeWxcSLRHRB5HZ8U4tz254fZwJWx99y3uof0SvH4awaBNye6ALg8u1BZwTWP+TfCu
         72kUym3IZw3eeifY62t944HxgyF41RvOZp8KYe7SuUL9EadI2X/338EZ5x4xGFbP16Yj
         CeVoZObASrTit9eNOFMCDrUKGrQZF5Ldj/0/nl4dJYAOFF2/SDhB0ciY7GfbsqVrQEIf
         u+qEeVhjkpCNP/sTnt9JubJewcBu95BFW0OdUtI31Kzx4ZBaLK9qkOAql/cbyrGipBsi
         m6tLgyByA0ofSnmZgh00s5NqDPUUH3KatW6l9NiHF1yIkIlduiPS5r4K3lHLF72/BHeg
         XXzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e18si485349qkg.244.2019.03.14.19.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 19:57:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2F2sRqC092087
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 22:57:55 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2r824rku2c-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 22:57:55 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 15 Mar 2019 02:57:55 -0000
Received: from b01cxnp23032.gho.pok.ibm.com (9.57.198.27)
	by e17.ny.us.ibm.com (146.89.104.204) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 15 Mar 2019 02:57:48 -0000
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2F2vkTu24313968
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 15 Mar 2019 02:57:46 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E663AAE060;
	Fri, 15 Mar 2019 02:57:45 +0000 (GMT)
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 019C2AE05C;
	Fri, 15 Mar 2019 02:57:36 +0000 (GMT)
Received: from [9.85.75.142] (unknown [9.85.75.142])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP;
	Fri, 15 Mar 2019 02:57:36 +0000 (GMT)
Subject: Re: [PATCH v6 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Alexandre Ghiti <alex@ghiti.fr>,
        Andrew Morton
 <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon
 <will.deacon@arm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>,
        "David S . Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
        x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
        Andy Lutomirski <luto@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-mm@kvack.org
References: <20190307132015.26970-1-alex@ghiti.fr>
 <20190307132015.26970-5-alex@ghiti.fr> <87va0movdh.fsf@linux.ibm.com>
 <e39f5b5b-efa1-c7b1-c1d8-89155b926027@ghiti.fr>
 <972208b7-5c05-cc05-efbf-0d48bff4cf77@linux.ibm.com>
 <b6259684-ddc0-ade4-1881-016b5e7fff66@ghiti.fr>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Fri, 15 Mar 2019 08:27:35 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <b6259684-ddc0-ade4-1881-016b5e7fff66@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19031502-0040-0000-0000-000004D269EF
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010760; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01174508; UDB=6.00606765; IPR=6.00955172;
 MB=3.00025982; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-15 02:57:54
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031502-0041-0000-0000-000008DD80A3
Message-Id: <a96fefc5-c7dc-a335-8d87-603a0be03ac6@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-15_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903150020
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/14/19 7:22 PM, Alexandre Ghiti wrote:
> 
> 
> On 03/14/2019 02:17 PM, Aneesh Kumar K.V wrote:
>> On 3/14/19 5:13 PM, Alexandre Ghiti wrote:
>>> On 03/14/2019 06:52 AM, Aneesh Kumar K.V wrote:
>>>> Alexandre Ghiti <alex@ghiti.fr> writes:
>>>>
>>
>>> Thanks for noticing Aneesh.
>>>
>>> I can't find a better solution than bringing back 
>>> gigantic_page_supported check,
>>> since it is must be done at runtime in your case.
>>> I'm not sure of one thing though: you say that freeing boottime 
>>> gigantic pages
>>> is not needed, but is it forbidden ? Just to know where the check and 
>>> what its
>>> new name should be.
> 
> You did not answer this question: is freeing boottime gigantic pages 
> "forbidden" or just
> not needed ?

IMHO if we don't allow runtime allocation of gigantic hugepage, we 
should not allow runtime free of gigantic hugepage. Now w.r.t ppc64, 
hypervisor pass hints about the gignatic hugepages via device tree 
nodes. Early in boot we mark these pages as reserved and during hugetlb 
init we use these reserved pages for backing hugetlb fs.

Now "forbidden" is not the exact reason. We don't have code to put it 
back in the reserved list. Hence I would say "not supported".

-aneesh

