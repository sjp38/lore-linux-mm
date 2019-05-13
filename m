Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A49CC04AAA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6BE62084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="W22kvYLf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6BE62084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF48A6B027A; Mon, 13 May 2019 10:39:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B56CC6B027B; Mon, 13 May 2019 10:39:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F8426B027C; Mon, 13 May 2019 10:39:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB256B027A
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:55 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z2so9986496iog.12
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=K8i6wzsowphEeVDFXNpunuRUppmUJV415MqqD0nUaBI=;
        b=qKVLh4C09kUMZkSesT7hs/4uvX+0wtWPs/1/03fAA8iEePcFMmSfNBII4/2TZBcJIQ
         QgLcv049X2CVoFMCN+x/BFVQ4zfCFdOmn0pyFBjnsHXa6LZAfo3XauT5IHK/P/Fp7nN6
         vDAteIQDzYCerc1dFTYvhJ6WIGp0HvsiGu2w9LMmCW6sDhYtiXYwWrhtwWnS3y+faYmy
         iNMIubILbeu8LQogHW9FksH7F8OsF1o4kg1pXVRBSWfr33/CgNvDtEdUua2VlhI/m3PF
         mCSYdugAimLzhudltBLOf02IljAg7WvQBMxmoVqw4KdSpBHgrMupPN3sZvxvRaxm2Ypk
         zZHA==
X-Gm-Message-State: APjAAAXhWuG8n75c/rIDhk7uFf/WWtAHFqy68Co5XT5IhuhxbSor/sJI
	8Ccy7/HbWtk1Crd0QVguyBdAz940NN9JBBzL7L7tnly2LTsbM18x5f/6MJRN21o5q7PJquM2E07
	hlz7v4hkj056nZhQvEP5qTLhv8yrkuh/gn+CNYz6D1gNDJo9xaoS2ab+nKo4uu00pVQ==
X-Received: by 2002:a24:5ec2:: with SMTP id h185mr21078501itb.19.1557758395268;
        Mon, 13 May 2019 07:39:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSjrcMyhd3iLiDNEvT5iYJdeTV4ms7y4kxXD/3s4evRRW7UbeoS7SvDSZDValgIBnCMG8e
X-Received: by 2002:a24:5ec2:: with SMTP id h185mr21078461itb.19.1557758394648;
        Mon, 13 May 2019 07:39:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758394; cv=none;
        d=google.com; s=arc-20160816;
        b=K5rZlNRJzzbPZcvA6ZPuZIdSdt53SQNaevlQ5rnbeYZWXpxw3bjXciaKF73F7t3lWC
         UKgWyncgLHwyiwgjpbBfeYpskWYbn8KeopXrLmKkg+Zvt5r+qCEY+LCIngY45JnGV/Z0
         sBW6BiOA05GmvYMTHCB3W1s9B66qB4gI8UnDfMwbMQkDK3OJtbPKRrdUhu0uP769VT8i
         US7/iwg+4/YtcU5QBNqCal893zZBDnyvzut1QtizpY+L4V4HQeY/nZDS7mKThK9WBORZ
         dLxDMIipt6XGex/ZIqhxtfvbH2fHOsAIlBg+6OXw7JSShuVowTbva9q5/k7OAY7y7JBw
         tpTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=K8i6wzsowphEeVDFXNpunuRUppmUJV415MqqD0nUaBI=;
        b=0PsTS69htCxmF5C+LhuVeSZEUE96ZtwSRw+MKMLswnRvfUGVsKD25qCWhI//8kd9uz
         8n2cZawEmmUtg9YTOamsGRHlESOHu0u4qW2C2EsqswbFdojUkj9qo5qXrFPW14UN4Hez
         9tSYisNNMawiIpeBIYtN1T06d0EuxbfJBaSa+a8xejGJnBas1u7SXP859tvU9AL8DijS
         ZBl7NsEKZLSRcrW5Xk1TZ/vFJEvkHcfYOUQM4OP9lgcQCI9xArWrF0J6M/oANGmcTCrU
         OdIE3hRwNez0MFMQSeQc5bqTeLxjet9/vyitdhFy4+lFEQ+mY1u9L4hKD8piZErXPis8
         lB5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=W22kvYLf;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l186si8093217itb.59.2019.05.13.07.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=W22kvYLf;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd2Tx194906;
	Mon, 13 May 2019 14:39:45 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=K8i6wzsowphEeVDFXNpunuRUppmUJV415MqqD0nUaBI=;
 b=W22kvYLfLPm+lj8NF2wS7sDx9KGLeptevfeDTUzv+GZagg1XtUp9vZNWcihPEkWLSaPG
 Lx/9JGXoffT/Eb0lGLC1sDrq7K90utKJBv6oHFBVipO5+pMWF/TFSJYeuAR0q5E3kmrb
 Z8y5MymYgg/n3HDgLeCgwZcunQle8i2tJ4Yh1yNjfZX7YXAq/W6CISOEnlueSKA6ARpD
 7dxEJ5PcvUpwerEg1uRhKhIlwA7KzrsVOb2FbKrBGoKH6oKfCK78Z0vuFk+sXe8ZpF4h
 vFYm9C8pwOMgg5LaQcKAYKtRiG+FEuIFLEcRxD9EaawYkjfOPClZpb0QoK/QdH7HCyaA Yg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2sdq1q7ayc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:45 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQP022780;
	Mon, 13 May 2019 14:39:42 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 22/27] kvm/isolation: initialize the KVM page table with vmx cpu data
Date: Mon, 13 May 2019 16:38:30 +0200
Message-Id: <1557758315-12667-23-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Map vmx cpu to the KVM address space when a vmx cpu is created, and
unmap when it is freed.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/vmx/vmx.c |   65 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index 5b52e8c..cbbaf58 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -6564,10 +6564,69 @@ static void vmx_vm_free(struct kvm *kvm)
 	vfree(to_kvm_vmx(kvm));
 }
 
+static void vmx_unmap_vcpu(struct vcpu_vmx *vmx)
+{
+	pr_debug("unmapping vmx %p", vmx);
+
+	kvm_clear_range_mapping(vmx);
+	if (enable_pml)
+		kvm_clear_range_mapping(vmx->pml_pg);
+	kvm_clear_range_mapping(vmx->guest_msrs);
+	kvm_clear_range_mapping(vmx->vmcs01.vmcs);
+	kvm_clear_range_mapping(vmx->vmcs01.msr_bitmap);
+	kvm_clear_range_mapping(vmx->vcpu.arch.pio_data);
+	kvm_clear_range_mapping(vmx->vcpu.arch.apic);
+}
+
+static int vmx_map_vcpu(struct vcpu_vmx *vmx)
+{
+	int rv;
+
+	pr_debug("mapping vmx %p", vmx);
+
+	rv = kvm_copy_ptes(vmx, sizeof(struct vcpu_vmx));
+	if (rv)
+		goto out_unmap_vcpu;
+
+	if (enable_pml) {
+		rv = kvm_copy_ptes(vmx->pml_pg, PAGE_SIZE);
+		if (rv)
+			goto out_unmap_vcpu;
+	}
+
+	rv = kvm_copy_ptes(vmx->guest_msrs, PAGE_SIZE);
+	if (rv)
+		goto out_unmap_vcpu;
+
+	rv = kvm_copy_ptes(vmx->vmcs01.vmcs, PAGE_SIZE << vmcs_config.order);
+	if (rv)
+		goto out_unmap_vcpu;
+
+	rv = kvm_copy_ptes(vmx->vmcs01.msr_bitmap, PAGE_SIZE);
+	if (rv)
+		goto out_unmap_vcpu;
+
+	rv = kvm_copy_ptes(vmx->vcpu.arch.pio_data, PAGE_SIZE);
+	if (rv)
+		goto out_unmap_vcpu;
+
+	rv = kvm_copy_ptes(vmx->vcpu.arch.apic, sizeof(struct kvm_lapic));
+	if (rv)
+		goto out_unmap_vcpu;
+
+	return 0;
+
+out_unmap_vcpu:
+	vmx_unmap_vcpu(vmx);
+	return rv;
+}
+
 static void vmx_free_vcpu(struct kvm_vcpu *vcpu)
 {
 	struct vcpu_vmx *vmx = to_vmx(vcpu);
 
+	if (kvm_isolation())
+		vmx_unmap_vcpu(vmx);
 	if (enable_pml)
 		vmx_destroy_pml_buffer(vmx);
 	free_vpid(vmx->vpid);
@@ -6679,6 +6738,12 @@ static void vmx_free_vcpu(struct kvm_vcpu *vcpu)
 
 	vmx->ept_pointer = INVALID_PAGE;
 
+	if (kvm_isolation()) {
+		err = vmx_map_vcpu(vmx);
+		if (err)
+			goto free_vmcs;
+	}
+
 	return &vmx->vcpu;
 
 free_vmcs:
-- 
1.7.1

