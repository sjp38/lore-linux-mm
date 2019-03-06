Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BC02C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 12:46:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2648420652
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 12:46:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2648420652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB42A8E0005; Wed,  6 Mar 2019 07:46:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D64248E0004; Wed,  6 Mar 2019 07:46:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B68588E0005; Wed,  6 Mar 2019 07:46:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7162E8E0004
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 07:46:01 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 17so12199785pgw.12
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 04:46:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=5YIfznRDATu8bCdsN/0TxxJGQYsMCDPLON9BDMvLanc=;
        b=LpHeC3QdRdfePV2Oylz2esVPUmLEdA+aZQ4vgQ3DNci9ZQm8Io8E6bClz4Gfl8NRNB
         tqyFeWMbyXNb78ThM7Q5iOhqriLAWrRAbBR60p/+6+R2tHKbTCfcFhlTvaVZOFjB07zg
         yQGQr4XNToIMw/1TR3A3tFbejg3YSV+++GB7uDN0AxJIW1Ozz+K9W8QpMXBLE8Cwr9Gg
         KCLdUY2pwzsSIWFO4p+2wgNHg8lrFtcY5pBgRrD7nTz8xozO7NbKrvAOhtbn1Pu0lMXA
         T+U8Tx4jzj7sqhJtkO+Cl9GAJG7R3luQZ3w/n6r795e2ssXUkB+ATrz2YHSw2fekBFoU
         KZcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV5Q5Y4LJH5qi3NXGlQxr0gUz3UTtjA1Talmc3sfiaHbrzlSFeq
	4ARUKxI9VJufngvuRTTCr3U9I6VfUtRjB8pPQLgYV8jhsHjNVL3MgJ8QW/ufAygqUpu8ABAzJkw
	gmC/1gZMn+bsPq3PTMNeGiuymJlebJCnN73hkM5+Wuop6qnW0++hMtaFZDimOFoW/Fw==
X-Received: by 2002:a63:2ad4:: with SMTP id q203mr6285842pgq.43.1551876361136;
        Wed, 06 Mar 2019 04:46:01 -0800 (PST)
X-Google-Smtp-Source: APXvYqxGk3OYwVpZSH1QgCf+rLyZ/xJb1TpLkDE8n8U22otJ5DeZ9b9HPE/P1bJ4CLmzZvh0/1Tv
X-Received: by 2002:a63:2ad4:: with SMTP id q203mr6285776pgq.43.1551876360117;
        Wed, 06 Mar 2019 04:46:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551876360; cv=none;
        d=google.com; s=arc-20160816;
        b=gv2R7R2X87kcCkbXziRyJpMO85O6WqQ3iwMpqs8S3ywFVcaiuqU9Vp1lp0839uyXTp
         70k9dXYyGGybDNNAyp4KYgL8a67O5PCgMEkRPuZJsOQ27zOqZnn8iEL0ehio8PAfTkL0
         6rcZ+v+CcwYY58YuNO0OBgGCjCybEKwMzXU9dIzm3EiE2kbXzSXNGEAmJUKdOYVfL7ag
         9xCfea6aZsauU73PQK49BMBLFSzhRYuIwg1F3ia2KeyqIddqQ7AckLZOixsYa1bLgCo6
         LyyW89WlNk68GyKQuetbV+qGTESb9bz1ltAp3BvWR8YQEm0MhLBAgPNE83a9pFbIG6QG
         IBzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=5YIfznRDATu8bCdsN/0TxxJGQYsMCDPLON9BDMvLanc=;
        b=Y3iFDIDH00hSEhY0VSYneYPzf72YA534m0f4UxH5Z3TGI6Gdr+KFpo/KRL1Hk/8meo
         BTa7tap5KAKh7KZfNiHToeTatFGTiWh6/LYho6nfvTBJwYm/DFr89SDd1tLGRrk6ptaV
         8HODURGhgu03/F6jkYDTearxvS3P9cZ40QuZtCqS9Tw56u3cv7SPnKsPoICKu6i9HI6B
         Vc7vBG2c8/3GgUUKO4Pzyr4IoXXYiEBNHxXn7SvGJhT5CgM/1jrsY+8JDDoOf5aPW+b4
         Jijt9bbmR8jGaEsLwr2uaR1sqdLwoTsakXV+XKylIW3FbJ6AkbrjWZZm/bt2qU2xDuI1
         wGfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k69si1372491pgd.135.2019.03.06.04.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 04:46:00 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x26CYiPK144168
	for <linux-mm@kvack.org>; Wed, 6 Mar 2019 07:45:59 -0500
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r2bm823uc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:45:58 -0500
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 6 Mar 2019 12:45:57 -0000
Received: from b01cxnp22035.gho.pok.ibm.com (9.57.198.25)
	by e12.ny.us.ibm.com (146.89.104.199) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 6 Mar 2019 12:45:53 -0000
Received: from b01ledav002.gho.pok.ibm.com (b01ledav002.gho.pok.ibm.com [9.57.199.107])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x26CjqnR24641564
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 6 Mar 2019 12:45:52 GMT
Received: from b01ledav002.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2DDDD124058;
	Wed,  6 Mar 2019 12:45:52 +0000 (GMT)
Received: from b01ledav002.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 91B85124055;
	Wed,  6 Mar 2019 12:45:28 +0000 (GMT)
Received: from [9.199.59.8] (unknown [9.199.59.8])
	by b01ledav002.gho.pok.ibm.com (Postfix) with ESMTP;
	Wed,  6 Mar 2019 12:45:27 +0000 (GMT)
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: =?UTF-8?Q?Michal_Such=c3=a1nek?= <msuchanek@suse.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Oliver <oohall@gmail.com>,
        Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>, Ross Zwisler <zwisler@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
 <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
 <87k1hc8iqa.fsf@linux.ibm.com> <20190306124453.126d36d8@naga.suse.cz>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Wed, 6 Mar 2019 18:15:25 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190306124453.126d36d8@naga.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19030612-0060-0000-0000-00000317A706
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010714; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01170428; UDB=6.00611703; IPR=6.00951068;
 MB=3.00025857; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-06 12:45:55
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030612-0061-0000-0000-000048858CD3
Message-Id: <df01bf6e-84a1-53fb-bf0c-0957af2f79e1@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-06_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=979 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903060087
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/6/19 5:14 PM, Michal Suchánek wrote:
> On Wed, 06 Mar 2019 14:47:33 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
> 
>> Dan Williams <dan.j.williams@intel.com> writes:
>>
>>> On Thu, Feb 28, 2019 at 1:40 AM Oliver <oohall@gmail.com> wrote:
>>>>
>>>> On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
>>>> <aneesh.kumar@linux.ibm.com> wrote:
>   
>> Also even if the user decided to not use THP, by
>> echo "never" > transparent_hugepage/enabled , we should continue to map
>> dax fault using huge page on platforms that can support huge pages.
> 
> Is this a good idea?
> 
> This knob is there for a reason. In some situations having huge pages
> can severely impact performance of the system (due to host-guest
> interaction or whatever) and the ability to really turn off all THP
> would be important in those cases, right?
> 

My understanding was that is not true for dax pages? These are not 
regular memory that got allocated. They are allocated out of /dev/dax/ 
or /dev/pmem*. Do we have a reason not to use hugepages for mapping 
pages in that case?

-aneesh

