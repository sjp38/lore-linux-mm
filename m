Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0F64C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 414ED20830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="npNl9oJA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 414ED20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1AEA6B026B; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A84546B0271; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 777346B026B; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F41E6B026D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id 186so14321820iox.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=rvo2MdeHWW3FffgXBOnUmvIQSFmvjV1SQw64yMoM6qw=;
        b=kV6O50HxrcfimKoveoNTv7be8f02pRdMQXFoL6YkRTu3+DdV/jETl03wq/yv1WNUTX
         d3f7QL8B560X+y6VykgowXSBna5UgbIGex8FLvVTU53o0G07z822v5zpLfsE2KQ39qXz
         wPcHlmuvjl78YvDEqTtC/RCbNeGy78IaZcRla9bN+b6xkSM3fHPTMek+1LI0J74vgDNw
         VsmaRZ59Pb8OqCPDK16wxOzJxXuX4aLJn6vLHJV5du/7UuFnincV22kLQg5ry3rI4esZ
         t4UMa074X8+/fU4wmvJxICqCkATv2TfVcMxCuPbadZVaNJk7BLKeYcvXUinQzy+Z8YVb
         vAfA==
X-Gm-Message-State: APjAAAW0NxiZJBs68tLOorgB6fb1GsBysHuJwrZNshBSnKQH60uAZYPr
	98IzNE6EJfwVtYrUoQieo89K67Sv0qdalFaV0r+07P+bDQFoeOvnPS550laOTHsv15QjJgVtJWw
	xW4d1/51S3oRTpGCZCTtrOBmvzSOweMQOVuo2XWV+ysjvc5or2c00iSXJ0io+FKEX4g==
X-Received: by 2002:a24:57c1:: with SMTP id u184mr1258911ita.38.1554313022104;
        Wed, 03 Apr 2019 10:37:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy28EjyvR4pH2LY5MnqF9K3cOMAs6rJxYuGBLWLefZ3FZDNPEfBjbs+WOoYaZ6dXyxrtAmf
X-Received: by 2002:a24:57c1:: with SMTP id u184mr1258856ita.38.1554313021210;
        Wed, 03 Apr 2019 10:37:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313021; cv=none;
        d=google.com; s=arc-20160816;
        b=LI8Wra2Ph/hG+gKjXUHegLLVHJgmmJFwOUa+1EBB4q+Z4jIq1fQpkwZRezyoV3cCib
         geSNNSYk/3lexfeH3hqSWQxvUOyQrzkuL4IVz08tZGlPXhNIcoetT56QwUmAr3o88oH2
         EX62+eI9LdHXypohZClGH3PzMqx+1BBZwUS9xhw8iczvbKgB3Wx/RavGvmBIfPTRpwEf
         kynfFJ3CbB/mW3k7pEiFuzA+0smHBZGfrF710tmSee+Xtq3rh9yqp+xQpQx1OetxFCyY
         d+kcRGqb9N+NKl0fFvvyHOnc09mtwXLcldU4aSaLpji+6T0EJfp3U+E8Thsuv9pP5Fq2
         lCxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=rvo2MdeHWW3FffgXBOnUmvIQSFmvjV1SQw64yMoM6qw=;
        b=oqwMGiZB1fXLZ+NXntRJImpOeltcrYu1qoI+/tRChDniZOGPKpwT9orE7ufrR57h7x
         v17ZMOZ62nBDoU5q5Rxc6drJChfzR6jfQi/oUd9kOVpLJbWAHc1zP9pMDznGchyeTbcA
         1tX0A6t6gn1V0j502Xzjaxye9EZbImcT7ApLNrnfWvcO8JeRPI0QF8MUcMUidLVv6mGK
         zB0zcpdtF/5oNUq0mY+weeIkzPYsQ8s+URXf1qkSfoJ5d1GzPJuLfUnOXYq/EanyeSiK
         3w2mqWFV8DjEJajKVfXHafbA4sxV86RSVeZwaSwPkOj7iLA+gV0CmEd6OlYpIe4zE1+0
         wPtg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=npNl9oJA;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a192si8597803ita.13.2019.04.03.10.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:37:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=npNl9oJA;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNhR0175372;
	Wed, 3 Apr 2019 17:36:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=rvo2MdeHWW3FffgXBOnUmvIQSFmvjV1SQw64yMoM6qw=;
 b=npNl9oJAhSwyoIUJBpUdDPF4JZ2CEYHDa3hUF0rsMUd/TEUZukdAVOkSbIAOjqZ6DnhF
 4PeMvlNZBGu3MlDHO96FNz7ZYY4KGvv7n5GotA4/y9ON0ExvPl/M9xWTwTgrYJlmrjPt
 KrY2ATZ/2p1EUBzuS+cPJ0H0Go+Gw49Ol8sGEGecBg6+4vpnuJRpl2iI+pGvq2WSHF5f
 cNT8uKqrqWkIzeQB8soGylpULikvh8aYZHPSbDYfFRqgwsMoWBi2heFAa2HwOw4ulleL
 bH5dtKuvZHXYPcnXA26kaww/oD554BWvyKYQjs0uON2qSiyZ7kHrJavD0EnUKzK+eaOS +A== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2rj13qae91-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:36:08 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HZIaq110901;
	Wed, 3 Apr 2019 17:36:07 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2rm8f5fym6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:36:07 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x33Ha2pB001570;
	Wed, 3 Apr 2019 17:36:02 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:36:02 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, aaron.lu@intel.com, akpm@linux-foundation.org,
        alexander.h.duyck@linux.intel.com, amir73il@gmail.com,
        andreyknvl@google.com, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, ard.biesheuvel@linaro.org, arnd@arndb.de,
        arunks@codeaurora.org, ben@decadent.org.uk, bigeasy@linutronix.de,
        bp@alien8.de, brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
        cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
        dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
        hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        james.morse@arm.com, jannh@google.com, jgross@suse.com,
        jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
        jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
        khalid.aziz@oracle.com, khlebnikov@yandex-team.ru, logang@deltatee.com,
        marco.antonio.780@gmail.com, mark.rutland@arm.com,
        mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
        mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
        m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
        paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
        rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
        rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
        rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
        serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
        vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
        yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
        ying.huang@intel.com, zhangshaokun@hisilicon.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org
Subject: [RFC PATCH v9 10/13] arm64/mm, xpfo: temporarily map dcache regions
Date: Wed,  3 Apr 2019 11:34:11 -0600
Message-Id: <a98c81d581e31b573b80ca9982e0325c3f542075.1554248002.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=677
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=687 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

If the page is unmapped by XPFO, a data cache flush results in a fatal
page fault, so let's temporarily map the region, flush the cache, and then
unmap it.

CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@tycho.ws>
---
v6: actually flush in the face of xpfo, and temporarily map the underlying
    memory so it can be flushed correctly

 arch/arm64/mm/flush.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
index 5c9073bace83..114e8bc5a3dc 100644
--- a/arch/arm64/mm/flush.c
+++ b/arch/arm64/mm/flush.c
@@ -20,6 +20,7 @@
 #include <linux/export.h>
 #include <linux/mm.h>
 #include <linux/pagemap.h>
+#include <linux/xpfo.h>
 
 #include <asm/cacheflush.h>
 #include <asm/cache.h>
@@ -28,9 +29,15 @@
 void sync_icache_aliases(void *kaddr, unsigned long len)
 {
 	unsigned long addr = (unsigned long)kaddr;
+	unsigned long num_pages = XPFO_NUM_PAGES(addr, len);
+	void *mapping[num_pages];
 
 	if (icache_is_aliasing()) {
+		xpfo_temp_map(kaddr, len, mapping,
+			      sizeof(mapping[0]) * num_pages);
 		__clean_dcache_area_pou(kaddr, len);
+		xpfo_temp_unmap(kaddr, len, mapping,
+				sizeof(mapping[0]) * num_pages);
 		__flush_icache_all();
 	} else {
 		/*
-- 
2.17.1

