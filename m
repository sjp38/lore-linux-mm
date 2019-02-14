Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87290C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:04:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 337AC218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:04:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="rq32CuBk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 337AC218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D51C68E0002; Wed, 13 Feb 2019 19:04:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D01668E0001; Wed, 13 Feb 2019 19:04:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7BA68E0002; Wed, 13 Feb 2019 19:04:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70FEF8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:04:44 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id a72so1285283pfj.19
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:04:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=sphrv7BG0r4M1etaGHVdl0ES/afYZFzSiF3kwKx/qUc=;
        b=o3OANTUU5h9sEJ8/qtNGY54K3qFrR1dW33WBP+w0mT6BMQco7Eu0ZmG/6EaTEWFrUC
         2E3OZR24YSn6d3woFFTpNoeVq+Oa2sjwOTqBOQ3xWWSEUdjRztGPXHf89GEkE/+EpMMA
         5FcmbBYyHCL9TP0oIizwQCkHZI6ZCo1HAp7EcO0nIdYuM81f9kb/LtMahDAXfx7jYH6t
         /jx8Ffd7/fJAHs9njYaIo+H3/1Sm/JcExxPSIsvSabX5sQO0Nj++RGuefTuVlo+v3CsI
         cErY95mazV1sJkes2Bs2vE8PNnhwgUweGtpxwNP7BWcrPNFmr+RxxvAxMlMuAvUEkSz1
         ewoA==
X-Gm-Message-State: AHQUAuZFc/cKbvePyqs324H9uKmtjnkMMXTTY3q2PUNjfb+2YKFdTfs3
	kmrNd6rIfIMVLh/I3xrzSUiJmIJehjlAGthn+EkAztjxMgHXLtI2t7N/fe4nTiRHseeq3pbmkFx
	PiAZBXTFFk2MccIKzFBNlPGdAz+3+btZEiL4vZe2ihclJW1WrMchULYC5DThIj773YQ==
X-Received: by 2002:a62:560f:: with SMTP id k15mr847520pfb.231.1550102684064;
        Wed, 13 Feb 2019 16:04:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbQ2m6yRlMun+ynZ8lGjJ0jr00kKDBZtXMGJGzlOEK/zd5IxWRxjyxU24rnsQAPOVnVfMQz
X-Received: by 2002:a62:560f:: with SMTP id k15mr847461pfb.231.1550102683359;
        Wed, 13 Feb 2019 16:04:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102683; cv=none;
        d=google.com; s=arc-20160816;
        b=ZVNMIdg9RHAxkM7t8wdoaDzXT0Xo1MUk9GqOyLUEMQFUIN07RsYmbyI47ItnOWkLxF
         BZvVdxLIiWAM2PAfj/ls1YASv/CfgiBDdbkQSfiI5oR7Gri1WoUGkH92/epw8iIDxXOO
         fy0ocoLwECyCLpN5CYK9mwEk21d17gxFTUwKeM7TNBvS4W0fO4aJe8BexRgSptlIzf6E
         Dru+mw2klD17SCHwy9K7e8ALdcD97rtJnYq3LL1yjy8z3jJNnhpW426SY3+oPsWrumT2
         N3KUfrXvJZtoNKgSIFWQmDlpPQ9JoyzRv4Nf1pO9751cbr5Fr+4PkuBOBR4V76Tnoym9
         tWYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=sphrv7BG0r4M1etaGHVdl0ES/afYZFzSiF3kwKx/qUc=;
        b=QWVatsAzwo3Ud1AVzAVEs2vAiP33sPdrcXJsiuNzTFxW3eCx8Elo0AN1P+WG1QiAeJ
         yYLcWdZa/FZXA/ZezM0j/t8ANU2qZIo0pgT2wvy5PjQkP4N6n8Q+Tmm+2eEVoWBfcuGe
         qBCNfJ5y0U0DzLZJ++WpO0waxkZ1rLAhl56++33+gmUXPslb0zZ+uk1D1xny6kozEhIY
         MPjrCIQnbVewYNh5OA5+BZhQ7VHmjrGg7mpCEe6XZrd71IXJcg5hSSNS/ybElc+Qosjr
         ujrKLbc2vFR45kZu7tOj6wJaqe+oxvWo6vP4NMr0Do5jWzuYOHiU+3CEn7Jq777VPgzH
         LiEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rq32CuBk;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 3si754247plv.258.2019.02.13.16.04.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:04:43 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rq32CuBk;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNxBhK099616;
	Thu, 14 Feb 2019 00:02:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=sphrv7BG0r4M1etaGHVdl0ES/afYZFzSiF3kwKx/qUc=;
 b=rq32CuBk5X2+Xev+zFjtWbTbukjVYgp052VQoUtKNOTE4Cda9Cy4Byz7X7TyDaf3TQ2I
 6Xq6h/PXDcwuH55t84HlJx++IE29KeYzxGnud9iAcqceAw++4jace2g3nP5q9+tVQuDP
 JKmeME1MBZxG+r3eijrKz+I+/dFivoWQvUM6OVeVIggnFDVOUMogq4PMOpJhjY4t+4Ty
 T/Rv6uXJl+x2rhUlCA5dHNltlK7OXjBzMdts964clZe9v6/2TNndXTWUZGdIWr0yX2HO
 Q8vLkyWbeiF65glX8gZob//mF1Popwb6C6Z2TLKwVkfbusnbRd8Lf2e8RxtLEG/+nZ1T cg== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2qhree55ng-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:27 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1E02QQh001435
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:26 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1E02OhA014525;
	Thu, 14 Feb 2019 00:02:25 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:02:24 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com,
        dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com,
        boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        oao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Khalid Aziz <khalid.aziz@oracle.com>,
        "Vasileios P . Kemerlis" <vpk@cs.columbia.edu>,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        Tycho Andersen <tycho@docker.com>,
        Marco Benatto <marco.antonio.780@gmail.com>,
        David Woodhouse <dwmw2@infradead.org>
Subject: [RFC PATCH v8 12/14] xpfo, mm: optimize spinlock usage in xpfo_kunmap
Date: Wed, 13 Feb 2019 17:01:35 -0700
Message-Id: <fb183dba421ad5cc1eda9acaf0678970bdf2159b.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Julian Stecklina <jsteckli@amazon.de>

Only the xpfo_kunmap call that needs to actually unmap the page
needs to be serialized. We need to be careful to handle the case,
where after the atomic decrement of the mapcount, a xpfo_kmap
increased the mapcount again. In this case, we can safely skip
modifying the page table.

Model-checked with up to 4 concurrent callers with Spin.

Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: x86@kernel.org
Cc: kernel-hardening@lists.openwall.com
Cc: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>
Cc: Tycho Andersen <tycho@docker.com>
Cc: Marco Benatto <marco.antonio.780@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 mm/xpfo.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/mm/xpfo.c b/mm/xpfo.c
index dc03c423c52f..5157cbebce4b 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -124,28 +124,35 @@ EXPORT_SYMBOL(xpfo_kmap);
 
 void xpfo_kunmap(void *kaddr, struct page *page)
 {
+	bool flush_tlb = false;
+
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
 
 	if (!PageXpfoUser(page))
 		return;
 
-	spin_lock(&page->xpfo_lock);
-
 	/*
 	 * The page is to be allocated back to user space, so unmap it from the
 	 * kernel, flush the TLB and tag it as a user page.
 	 */
 	if (atomic_dec_return(&page->xpfo_mapcount) == 0) {
-#ifdef CONFIG_XPFO_DEBUG
-		BUG_ON(PageXpfoUnmapped(page));
-#endif
-		SetPageXpfoUnmapped(page);
-		set_kpte(kaddr, page, __pgprot(0));
-		xpfo_flush_kernel_tlb(page, 0);
+		spin_lock(&page->xpfo_lock);
+
+		/*
+		 * In the case, where we raced with kmap after the
+		 * atomic_dec_return, we must not nuke the mapping.
+		 */
+		if (atomic_read(&page->xpfo_mapcount) == 0) {
+			SetPageXpfoUnmapped(page);
+			set_kpte(kaddr, page, __pgprot(0));
+			flush_tlb = true;
+		}
+		spin_unlock(&page->xpfo_lock);
 	}
 
-	spin_unlock(&page->xpfo_lock);
+	if (flush_tlb)
+		xpfo_flush_kernel_tlb(page, 0);
 }
 EXPORT_SYMBOL(xpfo_kunmap);
 
-- 
2.17.1

