Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6EEDC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F72D2084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Y9nXfUJN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F72D2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95B1C6B0275; Mon, 13 May 2019 10:39:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BDBA6B0277; Mon, 13 May 2019 10:39:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C42F6B0276; Mon, 13 May 2019 10:39:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2E26B0274
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:48 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id t7so9991700iod.17
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=bOd6NTuOO3w4Tse88wsGsS3lTxF7t3wBy812EA6WdBU=;
        b=HAqzUXcoP5AygszEcSDrHn/s34Ifxl0M53HmH66dG0JAROs/c2nCvLZUGvpSyfWpUG
         7uV8UVPW6EHTRa+yo4Cc5JGOc97XFPHAgUQHJZKvUHKdW4QrhGtVrsrZMhCbBj7/euxU
         6aPxXXBjpYecHyxEJSzwTqg7P2lA+XaFyAoDL1/OEO35NZ2xCkYRq3jcBM8If1S9kBKH
         bXWxKPyClU+7d9VN0qz7vF2B7pUB3QCoNLaRVVEhj+QxozC2zFAfjpafVLV+7S70DgU0
         CykNZr6CHR66kQDXHc2aDVYJYxDkXdG2zJ6RRQ9L4QQgoK8g/UseYxYyuO7xrdQ+yPKh
         oyig==
X-Gm-Message-State: APjAAAVYxT4T/BwM3syelq3V4OwiYHCBzz2QMfRTl2h21JzKvpMPhNfF
	zNNVGV7CVGWcGFmo1JXZU8fhnO52iVXaoXg3P3aYupwhDsmiFUZhs3EdlrJjjiWydK+6cnaWaIT
	T2NFD7wGUKQj8CIdqBPxeYFNfjS7nny7GbQrSjhy/jnerMw+GZ15l5WPZEacZrmB8zw==
X-Received: by 2002:a6b:6f08:: with SMTP id k8mr11352559ioc.104.1557758388065;
        Mon, 13 May 2019 07:39:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwacQS30NO8TdbhchRhWCO7+AAeD7BJizMLV0/DWnu9RBhwPaxBIluZo1GkJtF4dlfGzSt5
X-Received: by 2002:a6b:6f08:: with SMTP id k8mr11352525ioc.104.1557758387409;
        Mon, 13 May 2019 07:39:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758387; cv=none;
        d=google.com; s=arc-20160816;
        b=b7STVkggKOGNCA+g4wyDWRdooseMglbPM6an6J6QCqn+0Sz0mzkfaRzKYHfSg+PQ9x
         ny0RKTAX1sOGeY6/t1VmxcPoTcLTbN5kG18g7M7TtPDmQ4ChLG8BSByqeUjVgarcEUo8
         ZCJkFCnhgrrb/ZeOMWC9EzbUh8gwlwNgJKHfoNTCtNnVCJDb9e9C9+STqoMNKrJgPcO/
         0JLSHMLCHL2IdXJy33LdW5sqIb/w9ci5JSl1msFXAqytrlMRn0Xz1zqDCw8p0jdsKMYn
         de/7DTY97KOMdTQ4V7epIyqoNEKwrOWfT1osc5BoJIMIy42mteMVGfDdOQW2TrLAio+T
         6dJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=bOd6NTuOO3w4Tse88wsGsS3lTxF7t3wBy812EA6WdBU=;
        b=Hhxq/4S5Ev/uLjCSDALTQeP64BHWsDpAs1TXDfnQ1oF8pxqyjdTGn+MwVA2v5f6Y4d
         sfEgawjP6C4FCLtifDp+nTXUqS0LWVR+tOdcww2ZCelmOKfaFXMrVd/G5xn5dIwBeOjk
         Doo+VAUgRpfITTUmj8glSeOnXIz/vT17VRMa3b3zUZargyVVl+s5B4SfjY+P0oHg3COv
         pdP8iTNsHFCtu/IUJAR8zrYsBgG+7K201rsEEs3pw5zo4cufQg846yk23z/5zEQr2tpV
         wKRhglH1eKxPCg2ihuttS50O3Rei5dFFqqZK6f8BD+TEHFNewpKdvZnHq0jxnJv6mmfF
         M9lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Y9nXfUJN;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x197si3224008itb.72.2019.05.13.07.39.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Y9nXfUJN;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd3dB181544;
	Mon, 13 May 2019 14:39:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=bOd6NTuOO3w4Tse88wsGsS3lTxF7t3wBy812EA6WdBU=;
 b=Y9nXfUJNbdNXiy0WXZfnXcvJMfJnbW6Wd/jhOsfaH+Nku6LO73tegfk4kUXz6qGARmee
 jxG1wNCbZiHDX8SNNrTewc3cLIlDZsttlVSwGklecgW/HROVU+I3mtazS3Yvqh11anbo
 Zv4jHKjLPjfduxRLu4X8LAzZ3P36HyfHmP1W/DyLiXegpYJeMKnqKZFwITYW5qzlSHm5
 RtesqMSGG/6fDOLSNgWvXF9bfkYj0YrLp3UqSNuvKowRK44FvGuaRvjBi3RpZ0NPhj/l
 QmdYQ9IaU3TVKzTuW8I6wo8hxvktW9E/r6qI9QWOuBYsblTK3/WgBv+O9a9uDwsYhX/x cg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2sdnttfeja-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:39 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQL022780;
	Mon, 13 May 2019 14:39:31 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 18/27] kvm/isolation: function to copy page table entries for percpu buffer
Date: Mon, 13 May 2019 16:38:26 +0200
Message-Id: <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

pcpu_base_addr is already mapped to the KVM address space, but this
represents the first percpu chunk. To access a per-cpu buffer not
allocated in the first chunk, add a function which maps all cpu
buffers corresponding to that per-cpu buffer.

Also add function to clear page table entries for a percpu buffer.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   34 ++++++++++++++++++++++++++++++++++
 arch/x86/kvm/isolation.h |    2 ++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index 539e287..2052abf 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -990,6 +990,40 @@ void kvm_clear_range_mapping(void *ptr)
 EXPORT_SYMBOL(kvm_clear_range_mapping);
 
 
+void kvm_clear_percpu_mapping(void *percpu_ptr)
+{
+	void *ptr;
+	int cpu;
+
+	pr_debug("PERCPU CLEAR percpu=%px\n", percpu_ptr);
+	for_each_possible_cpu(cpu) {
+		ptr = per_cpu_ptr(percpu_ptr, cpu);
+		kvm_clear_range_mapping(ptr);
+	}
+}
+EXPORT_SYMBOL(kvm_clear_percpu_mapping);
+
+int kvm_copy_percpu_mapping(void *percpu_ptr, size_t size)
+{
+	void *ptr;
+	int cpu, err;
+
+	pr_debug("PERCPU COPY percpu=%px size=%lx\n", percpu_ptr, size);
+	for_each_possible_cpu(cpu) {
+		ptr = per_cpu_ptr(percpu_ptr, cpu);
+		pr_debug("PERCPU COPY cpu%d addr=%px\n", cpu, ptr);
+		err = kvm_copy_ptes(ptr, size);
+		if (err) {
+			kvm_clear_range_mapping(percpu_ptr);
+			return err;
+		}
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(kvm_copy_percpu_mapping);
+
+
 static int kvm_isolation_init_mm(void)
 {
 	pgd_t *kvm_pgd;
diff --git a/arch/x86/kvm/isolation.h b/arch/x86/kvm/isolation.h
index 7d3c985..3ef2060 100644
--- a/arch/x86/kvm/isolation.h
+++ b/arch/x86/kvm/isolation.h
@@ -18,5 +18,7 @@ static inline bool kvm_isolation(void)
 extern void kvm_may_access_sensitive_data(struct kvm_vcpu *vcpu);
 extern int kvm_copy_ptes(void *ptr, unsigned long size);
 extern void kvm_clear_range_mapping(void *ptr);
+extern int kvm_copy_percpu_mapping(void *percpu_ptr, size_t size);
+extern void kvm_clear_percpu_mapping(void *percpu_ptr);
 
 #endif
-- 
1.7.1

