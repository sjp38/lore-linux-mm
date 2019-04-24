Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5516C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:34:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 824CA2089F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:34:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 824CA2089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1349C6B0005; Wed, 24 Apr 2019 03:34:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BBF46B0006; Wed, 24 Apr 2019 03:34:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E79F66B0007; Wed, 24 Apr 2019 03:34:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 946FD6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:34:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id j3so9358632edb.14
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 00:34:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=PGIeyyW0aHT7wAY531ZRN0buOrMMO3XQFst6xyKzV4c=;
        b=neyZz0D3Xe/SLY3CtJnk73kerNhojC9vq6J6PpRb6PDd2xr3ru/clJqsG51HRu+5zJ
         RwupL6u+/Y0tpSWuNt1yMarjfVITdMo1+hTYRxSZQ1sRGb3VvYiYWlviR9NxjcnuelvV
         PUFdTWrCtzSN3RpZf1MqUpl+pXjwi3wNYq5Img/f4mJp2acyNYnQRHfd2xrfHVBMcub1
         /B4KAmHzSpr0MgEP+0oGyXC2GNSuO+rHKR87nsJjk49OOQR7hFWzxEroUmmu51kSxM+D
         NABlDq2+zcVRniX6dH8waxRMEojucQ1vht5AG2ZeiDvkSKCQNgmJikMO2fb8Vx7dF2c1
         ksxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW9zKC4FbUBT55tTLAHJYDpPv1NwesPuDkzEMRyiEoXkSVCJmQc
	6sd5pBMafin1yCtwY0O0TXiDnGE2pliNJi7y+VzsUwF9nnjsNKh5rdw0Z1ne0gICw+HsYlZQf+g
	To4cmKcYaXUFlLIKAkC+UTPakPrS0HxjjLEZw5xeXSRFePYNRwbhxEdD6VBGzztLMpw==
X-Received: by 2002:a50:fc99:: with SMTP id f25mr18444853edq.237.1556091244139;
        Wed, 24 Apr 2019 00:34:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuFmNNiGPk4l9r4QL06RTUZ6TNPKduViRunhZT5DgXUQ8RYPcxQ54+JiNTDd7UG3exOhrY
X-Received: by 2002:a50:fc99:: with SMTP id f25mr18444814edq.237.1556091243145;
        Wed, 24 Apr 2019 00:34:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556091243; cv=none;
        d=google.com; s=arc-20160816;
        b=CR3heItZ6i4MfSrGqgXiWHy2USOWciY6BKcVQg7y3AhRCSP4U6OPQyH1CzkZrOh/r6
         E+eqewOpStJuxwhWOi1+gNTUZStyXmcJbct3LLllhRJNjphfHTGR3SYimgYZVFF6+oWu
         lSdzy2dR2dT06R/lz3o2n5oJnDZKFQa09ygFm8LhGwbHxCXau9JkcFwLEQcYmdltG1VT
         uaDR4xyHrJQrEmIsjAWDaaaN4n/89A+tHt+No+yuFCLZ5XMFbqqWKN/NR9aQZyZTmMRX
         qEHnHvlaCorOB3N/7fVLb3G+4+eUvq8uhOdtT3zRzgTO8hubSM3cAxy0uErUX8tbjiDW
         7wbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=PGIeyyW0aHT7wAY531ZRN0buOrMMO3XQFst6xyKzV4c=;
        b=YzuIy/oFPiqZD7SqEWIh2TTH6t1o026t/x8bXJd5aHSk/MmcRKGYGOoQcGIk5ow1jE
         mEW0Wg3BU1lenLeyoqNUKS2KqiUe/ivZyNZS6D5DGh0ZR8oQz/yOsOQrCYPumGALlqQm
         4uPl7X6V2qETnWt0rkJ+GdmgYvVz54AsTe7NWsVtHRT/Kyb5ufByK6DH6NWqh2edAIbi
         MIecsWaBd0RZZmjUNHwXb3Gqalx8R5+dyNaYUESP2ZyEsq53WxZPA7/zE8vYFR5u2y72
         SC51pQOt7nnLqDBgBiIUpAar2IF3dWdTKBM2j+pZISDOGp7wOyDhfG4zlPdqUWrKtiTd
         Q97Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o19si258222ejb.254.2019.04.24.00.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 00:34:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3O7VTB5096354
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:34:01 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s2k61s1x6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:34:01 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Wed, 24 Apr 2019 08:33:59 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 08:33:48 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3O7XluQ58458312
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 07:33:47 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 351E1A4053;
	Wed, 24 Apr 2019 07:33:47 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C72CFA4059;
	Wed, 24 Apr 2019 07:33:44 +0000 (GMT)
Received: from [9.145.184.124] (unknown [9.145.184.124])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 24 Apr 2019 07:33:44 +0000 (GMT)
Subject: Re: [PATCH v12 00/31] Speculative page faults
To: Peter Zijlstra <peterz@infradead.org>,
        Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>,
        "Kirill A. Shutemov"
 <kirill@shutemov.name>,
        Andi Kleen <ak@linux.intel.com>, dave@stgolabs.net,
        Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
        aneesh.kumar@linux.ibm.com,
        Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, mpe@ellerman.id.au,
        Paul Mackerras <paulus@samba.org>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>,
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
        Mike Rapoport <rppt@linux.ibm.com>,
        LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
        haren@linux.vnet.ibm.com, Nick Piggin <npiggin@gmail.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org,
        x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
 <20190423093851.GJ11158@hirez.programming.kicks-ass.net>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Wed, 24 Apr 2019 09:33:44 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423093851.GJ11158@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042407-0016-0000-0000-00000272C3E4
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042407-0017-0000-0000-000032CF3377
Message-Id: <05df6720-7130-62fe-a71f-074b6fafff3e@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240065
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 23/04/2019 à 11:38, Peter Zijlstra a écrit :
> On Mon, Apr 22, 2019 at 02:29:16PM -0700, Michel Lespinasse wrote:
>> The proposed spf mechanism only handles anon vmas. Is there a
>> fundamental reason why it couldn't handle mapped files too ?
>> My understanding is that the mechanism of verifying the vma after
>> taking back the ptl at the end of the fault would work there too ?
>> The file has to stay referenced during the fault, but holding the vma's
>> refcount could be made to cover that ? the vm_file refcount would have
>> to be released in __free_vma() instead of remove_vma; I'm not quite sure
>> if that has more implications than I realize ?
> 
> IIRC (and I really don't remember all that much) the trickiest bit was
> vs unmount. Since files can stay open past the 'expected' duration,
> umount could be delayed.
> 
> But yes, I think I had a version that did all that just 'fine'. Like
> mentioned, I didn't keep the refcount because it sucked just as hard as
> the mmap_sem contention, but the SRCU callback did the fput() just fine
> (esp. now that we have delayed_fput).

I had to use a refcount for the VMA because I'm using RCU in place of 
SRCU and only protecting the RB tree using RCU.

Regarding the file pointer, I decided to release it synchronously to 
avoid the latency of RCU during the file closing. As you mentioned this 
could delayed the umount but not only, as Linus Torvald demonstrated by 
the past [1]. Anyway, since the file support is not yet here there is no 
need for that currently.

Regarding the file mapping support, the concern is to ensure that 
vm_ops->fault() will not try to release the mmap_sem. This is true for 
most of the file system operation using the generic one, but there is 
currently no clever way to identify that except by checking the 
vm_ops->fault pointer. Adding a flag to the vm_operations_struct 
structure is another option.

that's doable as far as the underlying fault() function is not dealing 
with the mmap_sem, and I made a try by the past but was thinking that 
first the anonymous case should be accepted before moving forward this way.

[1] 
https://lore.kernel.org/linux-mm/alpine.LFD.2.00.1001041904250.3630@localhost.localdomain/

