Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BE3EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:33:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B76802171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:33:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B76802171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 021D98E0005; Thu, 28 Feb 2019 07:33:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEE0C8E0001; Thu, 28 Feb 2019 07:33:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8D8C8E0005; Thu, 28 Feb 2019 07:33:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA5B48E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:33:04 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id j1so10862268qkl.23
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:33:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=4QyDTHPfRYUyg1uIzcnJWCSuhYjooEcwCquoDnPlT8Q=;
        b=mZ2MJbfx2h7caYoF9tYiZC7Jb3jt10jNday1s5Xl7Q95WyHgoNeJhCnhZB6tVfV5/u
         luH5LP0oj2ow/6Ap7CH5lzYGWJJ4UwiFaKhG3L/NCMNZ0gRNyKmHwxi0yKyZ+GYTev61
         2arDrSsBPYjmT/PefZ+YVht8KvLRVYOIu8YDYXrcCI6uLwS5xU2dRaNyh3Z2I7gveqqh
         f1aJiPTjSZd42YR5IMRnS2uUPkkfzWFkBD7cNuUnSqH5fINhz+n6boI+8oBjTkSEEPkU
         /M3oVTSv3LUWT+iYBzZc1z/QCfamfUbF1EL/lJ+9gAdEmobs3WlzB8/XfgLGa6vbdq5C
         1obQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuYQcMIXquZVLF9PvGSzCXP3AplDQsEWpzOEHd0qctbe1fLTO61z
	BbDT79eBrCEFcu4xPDQHvYA0kXpY/AVFVgggeWqYC91BC0OmWqwiMNypHau/qMpoVEmByLjNn1c
	Xl8ZuMTACSftBV/ts8roKGsWj4QRw7uxM2onOrjco8pS/xxEjvL0413R+0DfO3UXR2g==
X-Received: by 2002:ac8:2e92:: with SMTP id h18mr5907538qta.317.1551357184424;
        Thu, 28 Feb 2019 04:33:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib3wQkqmZZ7NPUA/NuYPwGWCoDY+FCFwpvSJM1YIjwWEZgdEyBso8m1eAkIVfpGSrtRszCV
X-Received: by 2002:ac8:2e92:: with SMTP id h18mr5907483qta.317.1551357183635;
        Thu, 28 Feb 2019 04:33:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551357183; cv=none;
        d=google.com; s=arc-20160816;
        b=C+inbnJV2QUMYlEmakFLNy3Kb+ptBjn9oSoAjvxBDcAe8V9+UojxMWaCDh/mmT3SaK
         JewCH4CmG6b5IWkBvS98FkTKoW1gsv2scBtCb0NQAxAvDQM8WDTnLA2VNRhVC7c2775O
         L6P+Y8iJjr5dR63z+5W1ACK8OWGD3FSfXQusnHFQZ0JAdmpNdf3soqHY2wYIEZen5Kr4
         TyawuTL49l0RqPUKc1SbpIOBK7qHB9jMTuKi7cUYgSmWr8MxmHXxDyCeSdtXJWxiB2rP
         MnRdyljdgEY+l40Dc/FcSH/JOLsPqFvRopt1rhstD2gbzXPlXg2/z0dDOw7IVvms7WGx
         rEAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=4QyDTHPfRYUyg1uIzcnJWCSuhYjooEcwCquoDnPlT8Q=;
        b=liCWTLQNIla4rSYPh5iBcRcPpM/PoKUzZA0Vrj2DakVxU8PKfVlIJONXR6ldqenvcf
         vWmu1HVvOdsnnlBy7bkNHlADPlfy3qRr+5iBvIlhi99bu9iAfVglB67al2PSVKD4tfc4
         zSOj2xOHLVgpGElyIRC9rBNwlXlD6oszkxVhxu2eRbYIaXM9vnbleY0vxumB5HXqTTNj
         hLkkBWgBslhCXqwn+gGW2SzvLBXESdJOjlAI3voXc1/cOZZcJJO0WeSpf4mt/+tDGuF1
         sw5Z0hFEGvJ3F5JLNw822LgoTUbEKWDFbiTx4wVTS+0ThTUj6YhRD7ZzoulIARNkDMb5
         MO8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q19si5226426qtq.258.2019.02.28.04.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 04:33:03 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1SCU43e100162
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:33:03 -0500
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qxfhn8mng-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:33:03 -0500
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 28 Feb 2019 12:33:02 -0000
Received: from b01cxnp22035.gho.pok.ibm.com (9.57.198.25)
	by e16.ny.us.ibm.com (146.89.104.203) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 28 Feb 2019 12:32:58 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1SCWvhx21299350
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 12:32:58 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DA460B2064;
	Thu, 28 Feb 2019 12:32:57 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 84842B206A;
	Thu, 28 Feb 2019 12:32:54 +0000 (GMT)
Received: from [9.199.36.171] (unknown [9.199.36.171])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 28 Feb 2019 12:32:54 +0000 (GMT)
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: Jan Kara <jack@suse.cz>
Cc: akpm@linux-foundation.org,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        mpe@ellerman.id.au, Ross Zwisler <zwisler@kernel.org>,
        "Oliver O'Halloran" <oohall@gmail.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        Dan Williams <dan.j.williams@intel.com>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
 <20190228094011.GB22210@quack2.suse.cz>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 28 Feb 2019 18:02:53 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190228094011.GB22210@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19022812-0072-0000-0000-000004017CE6
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010679; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01167572; UDB=6.00609977; IPR=6.00948186;
 MB=3.00025780; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-28 12:33:02
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022812-0073-0000-0000-00004B54013E
Message-Id: <2452a0b6-a90e-52b8-cb9f-0b5a7fafbe64@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-28_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=982 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902280087
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 3:10 PM, Jan Kara wrote:
> On Thu 28-02-19 14:05:22, Aneesh Kumar K.V wrote:
>> Add a flag to indicate the ability to do huge page dax mapping. On architecture
>> like ppc64, the hypervisor can disable huge page support in the guest. In
>> such a case, we should not enable huge page dax mapping. This patch adds
>> a flag which the architecture code will update to indicate huge page
>> dax mapping support.
>>
>> Architectures mostly do transparent_hugepage_flag = 0; if they can't
>> do hugepages. That also takes care of disabling dax hugepage mapping
>> with this change.
>>
>> Without this patch we get the below error with kvm on ppc64.
>>
>> [  118.849975] lpar: Failed hash pte insert with error -4
>>
>> NOTE: The patch also use
>>
>> echo never > /sys/kernel/mm/transparent_hugepage/enabled
>> to disable dax huge page mapping.
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> 
> Added Dan to CC for opinion. I kind of fail to see why you don't use
> TRANSPARENT_HUGEPAGE_FLAG for this. I know that technically DAX huge pages
> and normal THPs are different things but so far we've tried to avoid making
> that distinction visible to userspace.


I would also like to use the same flag. Was not sure whether it was ok. 
In fact that is one of the reason I hooked this to 
/sys/kernel/mm/transparent_hugepage/enabled. If we are ok with using 
same flag, we can kill the vma_is_dax() check completely.


-aneesh

