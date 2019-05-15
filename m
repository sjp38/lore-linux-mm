Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 955DCC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 12:53:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2046C2082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 12:53:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="NK1N5xkJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2046C2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83ED36B0005; Wed, 15 May 2019 08:53:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C9086B0006; Wed, 15 May 2019 08:53:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66A146B0007; Wed, 15 May 2019 08:53:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4354F6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 08:53:20 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id m66so1164185itm.2
        for <linux-mm@kvack.org>; Wed, 15 May 2019 05:53:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qqsyAWE2i/voQnpUJu/NRs+qTwt/c05VpPNY04BS1Jg=;
        b=CQQjd8guDdw0EhkE4LssR3CO26QpRVJNMWbs1eprlJa3mhDj2aPnkM3egNwSDKw6z+
         OWwfbtb7aMiU+6lYI62P/FaV1UZw5iGKQD8WD/obeqwYrvQ20xc9fiH7/3cF5xhfgRVx
         f90+7j2uUCWAAgyH5FtVPur9j4no5bPjrkkuRgScKUYm7xqPeMrtLq35Wee0sOb2uGV9
         kNZbBQblOoRJGD36PvuDcoRSuVGi5pjEjkCZ0AeLRn4F8X616KyEsec8hHJYyHsvUQDO
         ThTxwAYpRDtp0srMahb720Yzf8Xv/ZdS8WtuDH6hD/Eq9ZxeG4gOvuKGnPMqTAZKNEgP
         ExDA==
X-Gm-Message-State: APjAAAW8OTpTbq+dIVY1lDTwftYZjKXfNtiZaW3Hy0LVVW0ZrIYVZdlZ
	dYAMBzrn9BOlMKFfpUZBo4MavIUS30z7WQSEPcLWAxKCTFOZNA71qgltx2hPayip+r1+y0GokMk
	hBnDEAlapAFytGUj58/PSsQIBv7Od8Z5yXg2ocQkqX/rbMymZhhfTJ1pLBW9T20lWjQ==
X-Received: by 2002:a02:8585:: with SMTP id d5mr28243018jai.69.1557924799914;
        Wed, 15 May 2019 05:53:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzG/0A8dneq/5VJr8sFgkUZqvWjBPuBNuqCOzkMzIXosNVfQVROsbHwZHg6+Nmm/iDpNo0w
X-Received: by 2002:a02:8585:: with SMTP id d5mr28242963jai.69.1557924798772;
        Wed, 15 May 2019 05:53:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557924798; cv=none;
        d=google.com; s=arc-20160816;
        b=akik6fmYRHTXxn/8aZtgNIah2jin9dIc9Yor2EZB/WYCPSsJp2sRT6qbMSKOCT/eL8
         oXaeHKuZ3shwFD8rm7lqEKjRFP8wPZ26Tc73C/WL8PqQxKE8AULM1ymsjWvHTMHVvZL6
         QstzKrTSSt8VHq3dQAyaXvy5NGLKHxDLRet9obQluDkjgkd8crw93xxdoaki8Xn5rOYv
         XPdLVydd93XDIGEId2wdiqR5Ky4kYdGiSOomVSW57w4kGXI1qGslrMZd8YGkxrNjI3h9
         o1u4cfMxWoiGFlPNqAxwNrtQYd9YRWw39j66cGdjjMq0IZuUI20gRCdgqIbA8EYiPGZZ
         1rhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=qqsyAWE2i/voQnpUJu/NRs+qTwt/c05VpPNY04BS1Jg=;
        b=C+GyQKDIYaebwE/O8I258m8hRMbcCL9DkB/rySvRrDBKPI6dK12hR2u6sskRXmlayp
         +bpdh/lf/wTEVbyMfKDFv2cIjX4w4u6KTCTBrJs0ZC4yV5TLssMdt42LWMqZ+W0tpKA6
         5vdvf86SDx18Ko3H39Wvz6T5hvX827OiiDHTcud3nr3WlOrjFEy8NNJBKNcfOZJqUDz5
         2wWrhcQY6WIJRtyqj+cesXmx4LIMdcBjKZrqlznH/XHNBHW0JlP9ptEFSJAOW9j9QaMO
         0sQmjnY+SwkiodvBd/yPHSa2waWrFD1DXJBhCECiHaKVeuFis4y1Y3j3Pl7eKv2iBynX
         TaLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=NK1N5xkJ;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z20si1075254iod.130.2019.05.15.05.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 05:53:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=NK1N5xkJ;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4FCmdlc060905;
	Wed, 15 May 2019 12:53:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=qqsyAWE2i/voQnpUJu/NRs+qTwt/c05VpPNY04BS1Jg=;
 b=NK1N5xkJDCeLh4n4t5QRRa/QeUiCSiZ62sXI+pIViFP/bG4kce7PUYzx3CgY8gjYJWYG
 QGZPV5rp0I5IydXmkaIrqcS3703IpyPk74fRV1A8fvNG8J+whG30zwkGWzqpeDyLn5j8
 REvESvk1q1afxajKj2RMI6P3of80n0R4PhZnTtJHn+jnyV7mJS2VKrViFvw5N1V+OJjg
 UfTL0WpjgEEzw2spLdP0xMyx6jAPOd0E9va6CwCikusw+ND21CwKnjmjxBng9VcMNL3b
 uXar1ljkEbdQ6MUtrtBhJyks8FLTQxOp3I37wkGqnUJSpQFRV4Bvhw7HsvFK/WBsBTNZ /w== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2sdnttvj3v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 15 May 2019 12:53:00 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4FCpMpl025522;
	Wed, 15 May 2019 12:52:59 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2sggdutcgt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 15 May 2019 12:52:59 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4FCqs75023757;
	Wed, 15 May 2019 12:52:55 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 15 May 2019 05:52:54 -0700
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <b5ebe77f-14f5-5f87-a4bd-8befb71a9969@oracle.com>
Date: Wed, 15 May 2019 14:52:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905150082
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905150082
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Thanks all for your replies and comments. I am trying to summarize main
feedback below, and define next steps.

But first, let me clarify what should happen when exiting the KVM isolated
address space (i.e. when we need to access to the full kernel). There was
some confusion because this was not clearly described in the cover letter.
Thanks to Liran for this better explanation:

   When a hyperthread needs to switch from KVM isolated address space to
   kernel full address space, it should first kick all sibling hyperthreads
   outside of guest and only then safety switch to full kernel address
   space. Only once all sibling hyperthreads are running with KVM isolated
   address space, it is safe to enter guest.

   The main point of this address space is to avoid kicking all sibling
   hyperthreads on *every* VMExit from guest but instead only kick them when
   switching address space. The assumption is that the vast majority of exits
   can be handled in KVM isolated address space and therefore do not require
   to kick the sibling hyperthreads outside of guest.

   “kick” in this context means sending an IPI to all sibling hyperthreads.
   This IPI will cause these sibling hyperthreads to exit from guest to host
   on EXTERNAL_INTERRUPT and wait for a condition that again allows to enter
   back into guest. This condition will be once all hyperthreads of CPU core
   is again running only within KVM isolated address space of this VM.


Feedback
========

Page-table Management

- Need to cleanup terminology mm vs page-table. It looks like we just need
   a KVM page-table, not a KVM mm.

- Interfaces for creating and managing page-table should be provided by
   the kernel, and not implemented in KVM. KVM shouldn't access kernel
   low-level memory management functions.

KVM Isolation Enter/Exit

- Changing CR3 in #PF could be a natural extension as #PF can already
   change page-tables, but we need a very coherent design and strong
   rules.

- Reduce kernel code running without the whole kernel mapping to the
   minimum.

- Avoid using current and task_struct while running with KVM page table.

- Ensure KVM page-table is not used with vmalloc.

- Try to avoid copying parts of the vmalloc page tables. This
   interacts unpleasantly with having the kernel stack.  We can freely
   use a different stack (the IRQ stack, for example) as long as
   we don't schedule, but that means we can't run preemptable code.

- Potential issues with tracing, kprobes... A solution would be to
   compile the isolated code with tracing off.

- Better centralize KVM isolation exit on IRQ, NMI, MCE, faults...
   Switch back to full kernel before switching to IRQ stack or
   shorlty after.

- Can we disable IRQ while running with KVM page-table?

   For IRQs it's somewhat feasible, but not for NMIs since NMIs are
   unblocked on VMX immediately after VM-Exit

   Exits due to INTR, NMI and #MC are considered high priority and are
   serviced before re-enabling IRQs and preemption[1].  All other exits
   are handled after IRQs and preemption are re-enabled.

   A decent number of exit handlers are quite short, but many exit
   handlers require significantly longer flows. In short, leaving
   IRQs disabled across all exits is not practical.

   It makes sense to pinpoint exactly what exits are:
   a) in the hot path for the use case (configuration)
   b) can be handled fast enough that they can run with IRQs disabled.

   Generating that list might allow us to tightly bound the contents
   of kvm_mm and sidestep many of the corner cases, i.e. select VM-Exits
   are handle with IRQs disabled using KVM's mm, while "slow" VM-Exits
   go through the full context switch.


KVM Page Table Content

- Check and reduce core mappings (kernel text size, cpu_entry_area,
   espfix64, IRQ stack...)

- Check and reduce percpu mapping, percpu memory can contain secrets (e.g.
   percpu random pool)


Next Steps
==========

I will investigate Sean's suggestion to see which VM-Exits can be handled
fast enough so that they can run with IRQs disabled (fast VM-Exits),
and which slow VM-Exits are in the hot path.

So I will work on a new POC which just handles fast VM-Exits with IRQs
disabled. This should largely reduce mappings required in the KVM page
table. I will also try to just have a KVM page-table and not a KVM mm.

After this new POC, we should be able to evaluate the need for handling
slow VM-Exits. And if there's an actual need, we can investigate how
to handle them with IRQs enabled.


Thanks,

alex.

