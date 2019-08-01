Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 908F3C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:48:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 438AD20838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:48:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="TNptSZZ9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 438AD20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE8346B0266; Thu,  1 Aug 2019 14:48:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E98AA6B0269; Thu,  1 Aug 2019 14:48:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAE1F6B026A; Thu,  1 Aug 2019 14:48:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id B76716B0266
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:48:31 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id h67so54875617ybg.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:48:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=Ciezm0wiC/csO7UfdWXZ7gdzaa76ViA5xD+oUSRsxJA=;
        b=Ic3gI7Xi/+AAWGjJiteD/z9BpW5pd6Vl3SEcMBNPu+W8YTalRyFQq/4krvyVXAyhwX
         zwdyp3O854LxsHKJiWk+yXztlBeRMx0D4CFipyVfTaUQJEcZii+8CcjyINqK2IXkAH3R
         oyIpc90kazYi0bFiy/sowCGHa/3qUxovQUkFQdVcySXZ2fb3ri8L+A7gD/OjJMkMv6Ae
         hEd6c2BXwqKHNxy+Yej3S8ruTk9AdZJjj59ifiyRwjLm0xxCNaBpMDZX5cpZW/8aBQkE
         LMLyHIg14/RIrdM8xHzdV4SBYKs0qank5YuOJO2lCs9JiWxH7VKWBsAUPS5BkIUZAiZE
         cC2Q==
X-Gm-Message-State: APjAAAWNiWUgFRUBtt6rHiMADmQ5TFak905/MbeRVSPaB0HngleRZxoe
	Ex2bgu2QIBojVrmb1hJ4XHypWVsEWBQBzhFfmL7o3TcNO26maJmDlbrNAdXPA+p5oeVKlgN7OD1
	bU+xcX3ozICg2mVClQPwLmCjyTSTtCach/SXMBPpcVQZz2vPJMSw1SIzL+BDkknVPxQ==
X-Received: by 2002:a81:50a:: with SMTP id 10mr78094773ywf.129.1564685311456;
        Thu, 01 Aug 2019 11:48:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcr+x5OAsC/MjmEoqEjqXfHxLbTurL6FL4WgfpbtnhAnO5wRuFYhBbuI9F1lYndelHkb9b
X-Received: by 2002:a81:50a:: with SMTP id 10mr78094752ywf.129.1564685310894;
        Thu, 01 Aug 2019 11:48:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564685310; cv=none;
        d=google.com; s=arc-20160816;
        b=EqCRznTI0MuDMy5dJexPMUtTOnNEVzsnk4r6QVZSOMvJzvTornSUaAqfMEBhLRua7l
         EL+dS4qcXse7s1QmVr6yxiNnlWG62HMh65xbJJ798u1pYrDEyvX2t+GhcVsGJloOlVIh
         WMvXrVeAg0uUM51tNiEoJxoUK9Coi821hmXWN/C5TJWB0eUS2fe4j8nEunWOGgDHFfzR
         vY7lqxGbgw5nerknpfFEDvexwnSYwhOyFUPmug6KAHis3wizJ0/LoOc2NURe50G8CxhL
         itILE04Tpy3emAfi52rhWCbG+fHA0xiJqdaQX8oBtf4vQyLZvVvzTpZrm0V3pXupNUac
         vTnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=Ciezm0wiC/csO7UfdWXZ7gdzaa76ViA5xD+oUSRsxJA=;
        b=BiN2gSsaghm7TGRqc5gmqHS5zueWBpdL504oo1TpbxxPYpPybC++qo4nZxNNdAk8fz
         XH4s4FU4pPgZj2hi+Fpu0oSCdvOin5lD17wvoF5aAtTMPt45X3Y/OXExo2xh2nvjnYhs
         u3in7YNLv6uZdFo2Jl19nIb0RuCIWVZgnPRbss24yxYvefbiYCLAaClLygCyrkeZP0nq
         9HUury7cuks97ihfHG+y9RSlpIkJqAUf1bGp6UsQE5uL3NKs9dgxNMxYNduDe2z17n9u
         O+C/iPDu5GXFZr3WKi5IBXIDB/0rEyRlZ9oeH7umLiGAhMyfBWkRl2miL725OZstd6Ab
         ulhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=TNptSZZ9;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p124si15619036ybc.458.2019.08.01.11.48.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:48:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=TNptSZZ9;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x71IhorE008325
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 11:48:30 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=Ciezm0wiC/csO7UfdWXZ7gdzaa76ViA5xD+oUSRsxJA=;
 b=TNptSZZ9Cm/6Xu+L84EkdVGb6XQdPvaFcfpvwLEjrzdvVTpOYbgbDk+9OJlsMYOTNz+z
 pZ+DuveXikv0CVPNeHfVDar+faXgAH3YwLUhw8KYASkVYgvGWLiVcVR/EcAbImOZfiPH
 hyOSaNg9l7LH5/8iIBtQ4cY6Tta8obP+asw= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0089730.ppops.net with ESMTP id 2u43h7rkgs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:48:30 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 1 Aug 2019 11:48:29 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id AAF5062E1FCA; Thu,  1 Aug 2019 11:48:27 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <oleg@redhat.com>, <kernel-team@fb.com>,
        <william.kucharski@oracle.com>, <srikar@linux.vnet.ibm.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 0/2] khugepaged: collapse pmd for pte-mapped THP
Date: Thu, 1 Aug 2019 11:48:21 -0700
Message-ID: <20190801184823.3184410-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=620 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010194
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes v2 => v3:
1. Update vma/pmd check in collapse_pte_mapped_thp() (Oleg).
2. Add Acked-by from Kirill

Changes v1 => v2:
1. Call collapse_pte_mapped_thp() directly from uprobe_write_opcode();
2. Add VM_BUG_ON() for addr alignment in khugepaged_add_pte_mapped_thp()
   and collapse_pte_mapped_thp().

This set is the newer version of 5/6 and 6/6 of [1]. Newer version of
1-4 of the work [2] was recently picked by Andrew.

Patch 1 enables khugepaged to handle pte-mapped THP. These THPs are left
in such state when khugepaged failed to get exclusive lock of mmap_sem.

Patch 2 leverages work in 1 for uprobe on THP. After [2], uprobe only
splits the PMD. When the uprobe is disabled, we get pte-mapped THP.
After this set, these pte-mapped THP will be collapsed as pmd-mapped.

[1] https://lkml.org/lkml/2019/6/23/23
[2] https://www.spinics.net/lists/linux-mm/msg185889.html

Song Liu (2):
  khugepaged: enable collapse pmd for pte-mapped THP
  uprobe: collapse THP pmd after removing all uprobes

 include/linux/khugepaged.h |  12 ++++
 kernel/events/uprobes.c    |   9 +++
 mm/khugepaged.c            | 140 +++++++++++++++++++++++++++++++++++++
 3 files changed, 161 insertions(+)

--
2.17.1

