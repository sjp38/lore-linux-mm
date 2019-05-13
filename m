Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67A04C04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 203FD2084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="mJcTtw57"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 203FD2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0C056B026C; Mon, 13 May 2019 10:39:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A94296B026D; Mon, 13 May 2019 10:39:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 872A86B026E; Mon, 13 May 2019 10:39:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 647EF6B026D
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:24 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id t7so9968534iof.21
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=GS3GihsPyz7Y99NHOiQDTtmA0apAWQh5Zi8mHVLNyoo=;
        b=FLYyjDQcBuD4avZ+Qy/pj+cV38PJNjW9Mix+dRF5KIrLvTyQJejuOlFWpzcuMxZfu0
         USa2MiJl5dLCPwMdO0X0HWPdNcrea90UjWSWBx2ywn3Cbi7+e0WOStJK1Jd80JkTop+R
         4WbR1+17PZAAIv9MWjfC1JNGz8WyeD09fzMpu6+4Nczo8vJ1BOGQxXM67rEZPTW/xXzJ
         UhrXgxZzxoQn7dm6SXMOI2UziP11mu1fbsqRCODtmw+3PGZhyfrT5TG3spkb9YxuAjeq
         KXLcop1juMuR1vVoVRrDfNvP/bQ8lj0jBQmvHsSMUk82iOOVLB47M4DSqbJS1zyz703E
         RdNg==
X-Gm-Message-State: APjAAAV5WCkgg9Do5LpDUiste5MCb1Tf4cxKfcQo0NB3E3oRckX18Ea1
	o8HtbyBkOB111c0guELr38nNpNxWTj9A5UV0XtetRRlUT57UovBpM0pz9qomBzQypF8C76Gkfg1
	Cv56H6MOlPRJHT+sOyVsfx2zwuAE5TSGZwuXXeXongrd/haxdORybqhR5c1glijrP7Q==
X-Received: by 2002:a6b:c046:: with SMTP id q67mr17080730iof.157.1557758364147;
        Mon, 13 May 2019 07:39:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdbo7JLruPmcq4GNDhZvuhPWyq3SGvkcS+u81HPBOdD15TxIRqdvugTpsGX5FZzY3sDpwK
X-Received: by 2002:a6b:c046:: with SMTP id q67mr17080681iof.157.1557758363420;
        Mon, 13 May 2019 07:39:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758363; cv=none;
        d=google.com; s=arc-20160816;
        b=iA82Hb/iXOH2W8fS6BqNqH39ley0pD27DxfTxGbTCpnXIY1WkFDJYMM2e9JuRmDh6V
         4DgZv6KtEz1rDpJUwmPCKAta5moio224omhl0KdA1wVBEYMW0E684cBYfspO6AXAkvUZ
         dn+FWYp9faYJaEj/clhA3BHXn4vct7+XWW/LdDCxw08WvBalfHmUv3/8ivUSiMvxRDU0
         ++bEkVtS0tAJO6Zm2mFzEVXH8vU3GSIzV3+l0qHWw7PivHe/54aLvlt8K43kyaQgwaRP
         0YtxhmMeq6p2i/4Ofj9kp5w1hhB7UItG0ryzN0zoG85AZg7TlXxAHhPRGBauz9ZiAfzP
         p7Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=GS3GihsPyz7Y99NHOiQDTtmA0apAWQh5Zi8mHVLNyoo=;
        b=iZJIS1uSSblQRFIhJgTDTqsd/08RUlExVcA78YB4NtFhQKFSOmzxvA5Pk0QLgupf8T
         UQ/K/i3pmUYft2PH45utW4FcIr+2JaOwUixyZ/PGaWOsGqo9wSR/5o0KDIsZlp+Fi2Vj
         TGcJzI7lGvo3CkXPU/I2atlB2ajbmEMhmg6kfq41oqagfdsGwpPtD8sj3uFI8Eh1wmk4
         uK/dh1fktwwhJTUB6uOHuQTlrCGgNF5HvtxJDVFRq5P/ZVfTjqkjhDTUOljXeDmJRM54
         qdu1qSoUn/ZNIdaBEktJl16b9u1rIB4IMonv5qr5/F1upMii5h8o46YpmiwlKMUmXIJX
         n1GA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mJcTtw57;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b123si8132262ith.61.2019.05.13.07.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mJcTtw57;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DESlCI171427;
	Mon, 13 May 2019 14:38:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=GS3GihsPyz7Y99NHOiQDTtmA0apAWQh5Zi8mHVLNyoo=;
 b=mJcTtw571vBY/DqchePtoK+a2fMaLqNsWff99ts41cz3uW81AVh8k2kIjQIXfkadX5Q3
 6F/E6e4/O6myTDqiwNYcUSpAOVMeeIBt5z6sBwlWmvIiYKdfzx0Qg4nsfGs0iR0Ee/ws
 8fyDT/ryZpc/Obi/2zRq7DJqs0810bOvF26HLCD7ir3wtStKFUFAa7Ws6PKz+Pu1UJQL
 dU9UJa5EK8+LYETRyQ5DuH2DbGMtHYVtA2jgoPUK3ziD1XjXnCkAD9TDmm7V4635R9i5
 XflzqnTQJehHeZrV5CJoVBXa8ETCmtisHC5rPPYYhukBl0cMbZnPTDNSWhzzDSLkexDm Fw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2sdnttfecf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:38:54 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQ7022780;
	Mon, 13 May 2019 14:38:50 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 04/27] KVM: x86: Switch to KVM address space on entry to guest
Date: Mon, 13 May 2019 16:38:12 +0200
Message-Id: <1557758315-12667-5-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130102
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Liran Alon <liran.alon@oracle.com>

Switch to KVM address space on entry to guest and switch
out on immediately at exit (before enabling host interrupts).

For now, this is not effectively switching, we just remain on
the kernel address space. In addition, we switch back as soon
as we exit guest, which makes KVM #VMExit handlers still run
with full host address space.

However, this introduces the entry points and places for switching.

Next commits will change switch to happen only when necessary.

Signed-off-by: Liran Alon <liran.alon@oracle.com>
Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   20 ++++++++++++++++++++
 arch/x86/kvm/isolation.h |    2 ++
 arch/x86/kvm/x86.c       |    8 ++++++++
 3 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index 74bc0cd..35aa659 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -119,3 +119,23 @@ void kvm_isolation_uninit(void)
 	kvm_isolation_uninit_mm();
 	pr_info("KVM: x86: End of isolated address space\n");
 }
+
+void kvm_isolation_enter(void)
+{
+	if (address_space_isolation) {
+		/*
+		 * Switches to kvm_mm should happen from vCPU thread,
+		 * which should not be a kernel thread with no mm
+		 */
+		BUG_ON(current->active_mm == NULL);
+		/* TODO: switch to kvm_mm */
+	}
+}
+
+void kvm_isolation_exit(void)
+{
+	if (address_space_isolation) {
+		/* TODO: Kick sibling hyperthread before switch to host mm */
+		/* TODO: switch back to original mm */
+	}
+}
diff --git a/arch/x86/kvm/isolation.h b/arch/x86/kvm/isolation.h
index cf8c7d4..595f62c 100644
--- a/arch/x86/kvm/isolation.h
+++ b/arch/x86/kvm/isolation.h
@@ -4,5 +4,7 @@
 
 extern int kvm_isolation_init(void);
 extern void kvm_isolation_uninit(void);
+extern void kvm_isolation_enter(void);
+extern void kvm_isolation_exit(void);
 
 #endif
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 4b7cec2..85700e0 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7896,6 +7896,8 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
 		goto cancel_injection;
 	}
 
+	kvm_isolation_enter();
+
 	if (req_immediate_exit) {
 		kvm_make_request(KVM_REQ_EVENT, vcpu);
 		kvm_x86_ops->request_immediate_exit(vcpu);
@@ -7946,6 +7948,12 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
 
 	vcpu->arch.last_guest_tsc = kvm_read_l1_tsc(vcpu, rdtsc());
 
+	/*
+	 * TODO: Move this to where we architectually need to access
+	 * host (or other VM) sensitive data
+	 */
+	kvm_isolation_exit();
+
 	vcpu->mode = OUTSIDE_GUEST_MODE;
 	smp_wmb();
 
-- 
1.7.1

