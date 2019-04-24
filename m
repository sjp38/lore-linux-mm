Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B288C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:57:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1442E20693
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:57:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1442E20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95E626B0007; Wed, 24 Apr 2019 03:57:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90F236B0008; Wed, 24 Apr 2019 03:57:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D81E6B000A; Wed, 24 Apr 2019 03:57:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29CF16B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:57:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n25so9430439edd.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 00:57:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=Jqy+7Irjqwi5JH8YMaKnd2YgRaJWbIt+dG99Ju8s9x8=;
        b=XdpXj2GCmiPo414i1YU9qKjUa3M43i6g/Tw8tD1k2wM5biytckt6WiqS8vSc2OYmsr
         s7NIGf/PQucY70CNwMjNmymGS9kn3IN065UjDpKFZdwZzg53wGHRUw9GuMXWr1WDDYpy
         tcYH6Qr/UCkyTh+S6PIcQgDEWRMBVafWAMAmFPgva3Bmnj/iEVVp+Ilo67iqHC4W7hke
         GhFMeqjt2tVnEt07jEiNX1BqZGn9jnrlY6ARG4NAbWRBUD/jlG3abwTXkxMB9DIgntdb
         /PLzww/ZR/yLh6mT6HSfcz1y9FoGsIFJv4i49opvi43lSIcyaYGykfBwMWUzQS2ZoUT4
         HELw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXUGPI1bo+K074GPyEqLdeUrN3EglCLJ9Ve2ezzE5Rm/xhhHS9f
	5+nQHMb501LPz003xr53PNTcYuv2eASyDiyu/5VMNv/0rxQJkEikZu7n8XEvmwXCz+tLSu1ROtb
	2sir/MWd7LBvdQFPVp6sZBSusBNGEHvI9EjOC0OSfmMU1VmQxbt4L/qBwKhXebxh3DA==
X-Received: by 2002:a50:8bed:: with SMTP id n42mr19383149edn.72.1556092644681;
        Wed, 24 Apr 2019 00:57:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHWoiisrYY/kP/GoV1SG1wErzRpe2aqu70+VavRh4E6SDgx0Kgw6J3hW56fWOy3JJE8Dvh
X-Received: by 2002:a50:8bed:: with SMTP id n42mr19383109edn.72.1556092643716;
        Wed, 24 Apr 2019 00:57:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556092643; cv=none;
        d=google.com; s=arc-20160816;
        b=CuYxWXkDPbVlfxhQ1YkwzUejVZdlkIuGnmgPOtfvpy+U25gDuMW6c2xlBLHFkHqoyY
         n5NPsqTEQHl8Fa6LVH0zz/m4x8qTM1iD5SompDiKlKYksEvLB1RlZLbmd2SEp7CS0sss
         0HQF9WyffWFbAd+vdd9cR7xGFgWC81LYZ1I0p2/T9Pq4H4daiP86u9MZM69JR2RyyRXd
         SLUBDc8VTT1BWD1F0Yp0gcAkmtvsmNMaNHi0VnUb2hdjzTf3EM6FtChJL5Z9hIIZcMBT
         uStf+iz8SMWpSIBRmNtWOwjAbthE10EypEoF7koVGQqPz2X55LRHf0iMNATEtBvJ02af
         SALw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=Jqy+7Irjqwi5JH8YMaKnd2YgRaJWbIt+dG99Ju8s9x8=;
        b=dXFIEdHyNh5YYjVVJYv6yqSG0GwWXLTMKY2Qi/vD5iFu3qSDZcFvh1hMJnYL/l8fKi
         4Aq1e0Z/ZsIsX4pBt6c9yDXNMGS/gOujrng35DB1xhBvuVAUxNTbjNsDreo/YgLtxOUk
         iv6wOCWA27Ptsiw5iOGv7ocBGRn2CH3I076LK4QaGuJtO4SjyyDLKsMvVTZvB8xe1q4d
         s7IqCIA7w8thodgH2WzQaUG8tbgIiHDJ++oO+1shH4ZTdFwLvMs/AUFqIMPe4LM0z4Iq
         MPavWVbKxDfwoObczlmNyQqr22ftmME+aRhv6NB1Y6NEUzQtSB+KBVQI8L+73ylW8akl
         Ct6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d20si4051256eda.173.2019.04.24.00.57.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 00:57:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3O7nm5a137639
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:57:22 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s2k57a789-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:57:21 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Wed, 24 Apr 2019 08:57:19 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 08:57:10 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3O7v8vK29819118
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 07:57:08 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7DA4CA4051;
	Wed, 24 Apr 2019 07:57:08 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CFE5FA4040;
	Wed, 24 Apr 2019 07:57:05 +0000 (GMT)
Received: from [9.145.184.124] (unknown [9.145.184.124])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 24 Apr 2019 07:57:05 +0000 (GMT)
Subject: Re: [PATCH v12 21/31] mm: Introduce find_vma_rcu()
To: Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, kirill@shutemov.name,
        ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz,
        Matthew Wilcox <willy@infradead.org>, aneesh.kumar@linux.ibm.com,
        benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Jerome Glisse <jglisse@redhat.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
        paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
        linuxppc-dev@lists.ozlabs.org, x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-22-ldufour@linux.ibm.com>
 <20190423092710.GI11158@hirez.programming.kicks-ass.net>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Wed, 24 Apr 2019 09:57:05 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423092710.GI11158@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042407-0012-0000-0000-00000312C636
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042407-0013-0000-0000-0000214B1A4D
Message-Id: <ea141f88-a0d3-df97-5141-706fa18b7ad3@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=907 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 23/04/2019 à 11:27, Peter Zijlstra a écrit :
> On Tue, Apr 16, 2019 at 03:45:12PM +0200, Laurent Dufour wrote:
>> This allows to search for a VMA structure without holding the mmap_sem.
>>
>> The search is repeated while the mm seqlock is changing and until we found
>> a valid VMA.
>>
>> While under the RCU protection, a reference is taken on the VMA, so the
>> caller must call put_vma() once it not more need the VMA structure.
>>
>> At the time a VMA is inserted in the MM RB tree, in vma_rb_insert(), a
>> reference is taken to the VMA by calling get_vma().
>>
>> When removing a VMA from the MM RB tree, the VMA is not release immediately
>> but at the end of the RCU grace period through vm_rcu_put(). This ensures
>> that the VMA remains allocated until the end the RCU grace period.
>>
>> Since the vm_file pointer, if valid, is released in put_vma(), there is no
>> guarantee that the file pointer will be valid on the returned VMA.
> 
> What I'm missing here, and in the previous patch introducing the
> refcount (also see refcount_t), is _why_ we need the refcount thing at
> all.

The need for the VMA's refcount is to ensure that the VMA will remain 
until the end of the SPF handler. This is a consequence of the use of 
RCU instead of SRCU to protect the RB tree.

I was not aware of the refcount_t type, it would be better here to avoid 
wrapping.

> My original plan was to use SRCU, which at the time was not complete
> enough so I abused/hacked preemptible RCU, but that is no longer the
> case, SRCU has all the required bits and pieces.

When I did test using SRCU it was involving a lot a scheduling to run 
the SRCU callback mechanism. In some workload the impact on the 
perfomance was significant [1].

I can't see this overhead using RCU.

> 
> Also; the initial motivation was prefaulting large VMAs and the
> contention on mmap was killing things; but similarly, the contention on
> the refcount (I did try that) killed things just the same.

Doing prefaulting should be doable, I'll try to think further about that.

Regarding the refcount, I should I missed something, this is an atomic 
counter, so there should not be contention on it but cache exclusivity, 
not ideal I agree but I can't see what else to use here.

> So I'm really sad to see the refcount return; and without any apparent
> justification.

I'm not opposed to use another mechanism here, but SRCU didn't show good 
performance with some workload, and I can't see how to use RCU without a 
reference counter here. So please, advise.

Thanks,
Laurent.

[1] 
https://lore.kernel.org/linux-mm/7ca80231-fe02-a3a7-84bc-ce81690ea051@intel.com/

