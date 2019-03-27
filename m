Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69308C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 10:05:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D0A92070B
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 10:05:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D0A92070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1D876B0003; Wed, 27 Mar 2019 06:05:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCD856B0006; Wed, 27 Mar 2019 06:05:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A95626B0007; Wed, 27 Mar 2019 06:05:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB976B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 06:05:34 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z34so16364314qtz.14
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 03:05:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:in-reply-to:references:date:mime-version
         :content-transfer-encoding:message-id;
        bh=0vWtgQh+qqPfs0IeoVQUYu2KfkJnnevA4rk3QkeKwI4=;
        b=NGTqxsteH/4QhjOlBtDBI5tUS3FfWypUkRlSl5gitb1zKeG/GF942/l9TrXdldDgPz
         93P+sm1qLa3gkhprje1VMw+LMgM2DX/KfiU+aXQ1RzyR6kFH63hgoe50UvfwmGpGimTv
         dj2INwUSKlskqMQnO4Z+jzzeHIGJ2nyi1jDmjWvp6GxNVI9dJBeiOU8WOGn8E9jQA5yW
         RQGUN9VjL1mCLZrS6pv8wjDDJHYdPw/4AuwQM86rrAhB0HqpvUVoN5SsYTFdMo0go84S
         uLAIte1P31EkhhFNtiA5945BsHqSpPHk747yIERKCJwh/mvD657Zh96Mo+dWMrq4OSTR
         4UTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUVoOqcnP9KrTk4Sb8XcGEifP4EOEQPUuH2DCxsc8rrtVYUk3nj
	67N/oA5uFoSPG2FlnRNBseSxlQEhTNIBMdSD4uKlcILDpHybwOZh7KRYnzOArbvMpdRz/5rzgDp
	XLzAkq+3nDU3L9thM/ftVnjYm5FRm5tXJpsB0gyCQmKyymxIJXfMS/7u3ZvZjYjFjJg==
X-Received: by 2002:a0c:81a1:: with SMTP id 30mr28910307qvd.230.1553681134261;
        Wed, 27 Mar 2019 03:05:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLgUGmUlAAGeAuoG2Z37K5jsUvSMcXgATj6iY1CPs9CPdXw00QR/ilSTMhN6I5WJjnHpj6
X-Received: by 2002:a0c:81a1:: with SMTP id 30mr28910252qvd.230.1553681133557;
        Wed, 27 Mar 2019 03:05:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553681133; cv=none;
        d=google.com; s=arc-20160816;
        b=uzdzSu6DHRpeKiIMo9tjEI0byTMA/8hvb/klpt/emSsqW1dXDy2n3v1v4fC7OTQHqv
         lDuwh0mAkQyUS/9+kaJIGZzeK1nkN6xvl5E9OCk6T8M49d1LSMyivkol3BDNYqMURKgj
         Uwj4zmsfpdDSBAxngWWXWig27pBONQjMRIyDCvulmDSxlMKRbatEcsD/gfRAhCW49qbj
         3fXn4FBVMwsRzhxL0pm7azelKuwAFzE/XT7FL+x4acyvIA6T+fBTIatdo3MU4qk+nXVx
         HCl2Q9OjmNOWVIRwi8StZk7V67mx+OMMgEndZhk01nX5vzC3F3oQKVD85yFCV4EEC4Pn
         0Q2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:references
         :in-reply-to:subject:to:from;
        bh=0vWtgQh+qqPfs0IeoVQUYu2KfkJnnevA4rk3QkeKwI4=;
        b=dqeUd3NWVm2ZdoAYMd7vBj1bEwWW8/m5NcODfT88pXIMEClzF/cM02H+sw9FIriafC
         1Fjq/2ucaeEP+ySBZHlqZwHsLtwiPMXx7HxVh0taUWL4Ya4QXNAszknI4cmk3OrfhQLr
         mR4IBLL8kLcYBOd6UjcfcMLs9D4IbG2PBQWTJwNzdPq/2FYEI8U4I4B0DLND+ou9EkIk
         x4QX/xqt+eatpOEPijCVKGc9NJShf5+0aS0W6pqfaVNXM+ehjfkfy3kUF7RdLWjLCdol
         Vuq68tSs3NA/D5K9OIvpow6su9LWb2xMRG50sRly6ZVu8p2V5IGOC0IKIArX1WRgBsae
         NCoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j19si4263765qkl.185.2019.03.27.03.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 03:05:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2RA4lBt103300
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 06:05:33 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rg6vwrpj0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 06:05:32 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 27 Mar 2019 10:05:30 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 27 Mar 2019 10:05:22 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2RA5Ld536831236
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Mar 2019 10:05:21 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AA8ADAE045;
	Wed, 27 Mar 2019 10:05:21 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 44B49AE051;
	Wed, 27 Mar 2019 10:05:15 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.102.0.57])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 27 Mar 2019 10:05:15 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Alexandre Ghiti <alex@ghiti.fr>, mpe@ellerman.id.au,
        Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
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
Subject: Re: [PATCH v8 4/4] hugetlb: allow to free gigantic pages regardless of the configuration
In-Reply-To: <e7637427-5f17-b4f4-93a2-70cac9b3a264@ghiti.fr>
References: <20190327063626.18421-1-alex@ghiti.fr> <20190327063626.18421-5-alex@ghiti.fr> <f6e74ad8-acca-3b1e-27eb-a2881ac8437d@linux.ibm.com> <fbae7220-2e6f-8516-cf93-fbe430452043@ghiti.fr> <aabfc780-1681-c69a-9927-4645d6499984@linux.ibm.com> <e7637427-5f17-b4f4-93a2-70cac9b3a264@ghiti.fr>
Date: Wed, 27 Mar 2019 15:35:13 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-TM-AS-GCONF: 00
x-cbid: 19032710-4275-0000-0000-0000031FC8B0
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032710-4276-0000-0000-0000382E6206
Message-Id: <87pnqcws2u.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-27_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903270073
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Alexandre Ghiti <alex@ghiti.fr> writes:

> On 03/27/2019 09:55 AM, Aneesh Kumar K.V wrote:
>> On 3/27/19 2:14 PM, Alexandre Ghiti wrote:
>>>
>>>
>>> On 03/27/2019 08:01 AM, Aneesh Kumar K.V wrote:
>>>> On 3/27/19 12:06 PM, Alexandre Ghiti wrote:
>

.....

>>
>> This is now
>> #define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
>> static inline bool gigantic_page_runtime_supported(void)
>> {
>> if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return false;
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0return true;
>> }
>>
>>
>> I am wondering whether it should be
>>
>> #define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
>> static inline bool gigantic_page_runtime_supported(void)
>> {
>>
>> =C2=A0=C2=A0 if (!IS_ENABLED(CONFIG_CONTIG_ALLOC))
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return false;
>
> I don't think this test should happen here, CONFIG_CONTIG_ALLOC only allo=
ws
> to allocate gigantic pages, doing that check here would prevent powerpc
> to free boottime gigantic pages when not a guest. Note that this check
> is actually done in set_max_huge_pages.
>
>
>>
>> if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return false;
>
> Maybe I did not understand this check: I understood that, in the case=20
> the system
> is virtualized, we do not want it to hand back gigantic pages. Does this=
=20
> check
> test if the system is currently being virtualized ?
> If yes, I think the patch is correct: it prevents freeing gigantic pages=
=20
> when the system
> is virtualized but allows a 'normal' system to free gigantic pages.
>
>
>>

Ok double checked the patch applying the the tree. I got confused by the
removal of that #ifdef. So we now disallow the runtime free by checking
for gigantic_page_runtime_supported() in  __nr_hugepages_store_common.
Now if we allow and if CONFIG_CONTIG_ALLOC is disabled, we still should
allow to free the boot time allocated pages back to buddy.

The patch looks good. You can add for the series

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

-aneesh

