Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D75F6C48BE3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F8C52089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YNs3gx+c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F8C52089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 457066B000D; Mon, 24 Jun 2019 01:43:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 408168E0002; Mon, 24 Jun 2019 01:43:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A6B68E0001; Mon, 24 Jun 2019 01:43:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9AD86B000D
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:39 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d190so8880307pfa.0
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5WJArPRhLKawZExF1a/OJKFWf27gCJZIRATflv1f+LA=;
        b=q2Dveix6wpMta/ym3PQ/cVjiUkSvrQDzXCQBPo4iT2EIZF3HQ4sePz9r9DADD1PUit
         JPALFWnIccWPNCOdp5V/jwojE0RrYFS6ctdeHnRP+qO8KJR2SlaWntMQ1TV64QxQGPLT
         5DYQfu7QIwjK0X3jjY0cKa+LVtQvu4cnHstAWREnwunPY3fflnS5jiZlNSIMCatVAo/c
         1tNkXUMfUu3e5zTI6mlkwyBIIqrgG/4XzQ6xraKqndhgokj7XI5DiH4HU2BIoDVFq8lV
         tcXZJd7jyK6Fs9GOijsTG4AVaqTHw0cmzU5m7C7IYj3CeEyCq7blB59pLYGkEro0FABM
         AXHg==
X-Gm-Message-State: APjAAAUvdbM1m0g/mGARQlPYg6fMNE8fdAFyvge5GsRHgsx484JHSlUJ
	3XOZGXmtNO/Eg+Mp8YbzXA4Fj8vSM2lIRlcr/SPRtcVqXvaoJLuafe9aqQmNeG5zGMk2Ne1MjvT
	ob+/S0h8aBA+P7WfAWhshvDwo2olwiFYP3pfcIFJrYDHFw/+yoD14MiwBgFcI5M8=
X-Received: by 2002:a63:7945:: with SMTP id u66mr5025540pgc.127.1561355019489;
        Sun, 23 Jun 2019 22:43:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz379UeVOpSClnSb+pjSENLDD2UAa2vzt4WlD3jMgoLaY5k3RU+CbgAIqwNslSQckpECHv8
X-Received: by 2002:a63:7945:: with SMTP id u66mr5025499pgc.127.1561355018735;
        Sun, 23 Jun 2019 22:43:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355018; cv=none;
        d=google.com; s=arc-20160816;
        b=kV9hRarkVYAQ61urPlzmfVM5aGSQx6NUkQmhEwIFfgd+MHBr3CkUZR1e/dH0D7v+67
         rf5MZ3We70QnMKYwcHIzAzRwlkKIgxlzuDOCttBYXUofoPgfDLQxq9wc94dZCQYshtD9
         pDNESCusCaXJRPe/ITCnPxNop8u8sikMgjN0SSPyFDbgACuHH1RCeol1t6eryeze6HV0
         6HBHxMzQqUNsf2oa0wvV81yHJX53Gk091Fg8CV/OvJeNsarjFY7DyGZHGF7Nw9WYsw8/
         gG6XL+bROZAGTBojzJL0UNxXRHu6BwVrz/gC1ilJAX/RuaJVbGf+5GUrzcHXD189lk4D
         gW3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5WJArPRhLKawZExF1a/OJKFWf27gCJZIRATflv1f+LA=;
        b=R6QmQxrBuHvqtimsPJhEQNWDsT0+ALNAKAhAPQACf8qqiD64mQZhoSwz6Y5lmovd2a
         Chin28CrKWrme1c0LwWm2g9eeszuKqdi7LMxD+OJo3yap4E22aukPxTsb009TrrVSX9d
         y4+pDZ73qdQy4lySs326VVNf9ejXVSYnleDUVwltGRtAXMfaHOzJZ6eg576ZpxNfzWAM
         LmcwMJVYKE1EAIjNh7GbDxY7H8FP5faUcTvnlvoQIxDlhRwPlkZa6m1dcjsUn3hY7/Ly
         imRY+azAkq4enRP5yZ2vz0eAYS9pz8MdUsdeyU6AJhRbwBF4FvwU0Z2IUYhrsNI0+7e5
         QMjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YNs3gx+c;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n1si3813539plk.388.2019.06.23.22.43.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YNs3gx+c;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=5WJArPRhLKawZExF1a/OJKFWf27gCJZIRATflv1f+LA=; b=YNs3gx+cZZv1ocI36RZcvQyY9T
	QTQAtNYVUae846VvayO26Eo+iWXkBfk4QXQM6mmZ5W6Zx0yJsWF18x+cP04E4Yy/Qu+9KKD8R4nRm
	HUfGGHLa7joE4G/VLRECg18AwszpPm3Dm/vU5chIb9rtFkH8A/EDQCh6t/mX19oO6tHcN1wx9YlGf
	J9IRgkwvTb8sJ4unejzwORv8IR/ev5ze7WeDv/2sC7ro8hXmHsJjeh4WUn9fJNDBEKBqyzxGctyDo
	nOQDQkr2twVVOQPP4YTh47PUmzt9r88vq5a82lkOHFOHV54/hbA3uXyXBxpCBr+tJrhKc77DWOAZG
	ZY9VAwnA==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlP-0006JM-V8; Mon, 24 Jun 2019 05:43:36 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 06/17] riscv: refactor the IPI code
Date: Mon, 24 Jun 2019 07:43:00 +0200
Message-Id: <20190624054311.30256-7-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190624054311.30256-1-hch@lst.de>
References: <20190624054311.30256-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This prepare for adding native non-SBI IPI code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/kernel/smp.c | 55 +++++++++++++++++++++++------------------
 1 file changed, 31 insertions(+), 24 deletions(-)

diff --git a/arch/riscv/kernel/smp.c b/arch/riscv/kernel/smp.c
index 5a9834503a2f..8cd730239613 100644
--- a/arch/riscv/kernel/smp.c
+++ b/arch/riscv/kernel/smp.c
@@ -78,13 +78,38 @@ static void ipi_stop(void)
 		wait_for_interrupt();
 }
 
+static void send_ipi_mask(const struct cpumask *mask, enum ipi_message_type op)
+{
+	int cpuid, hartid;
+	struct cpumask hartid_mask;
+
+	cpumask_clear(&hartid_mask);
+	mb();
+	for_each_cpu(cpuid, mask) {
+		set_bit(op, &ipi_data[cpuid].bits);
+		hartid = cpuid_to_hartid_map(cpuid);
+		cpumask_set_cpu(hartid, &hartid_mask);
+	}
+	mb();
+	sbi_send_ipi(cpumask_bits(&hartid_mask));
+}
+
+static void send_ipi_single(int cpu, enum ipi_message_type op)
+{
+	send_ipi_mask(cpumask_of(cpu), op);
+}
+
+static inline void clear_ipi(void)
+{
+	csr_clear(CSR_SIP, SIE_SSIE);
+}
+
 void riscv_software_interrupt(void)
 {
 	unsigned long *pending_ipis = &ipi_data[smp_processor_id()].bits;
 	unsigned long *stats = ipi_data[smp_processor_id()].stats;
 
-	/* Clear pending IPI */
-	csr_clear(CSR_SIP, SIE_SSIE);
+	clear_ipi();
 
 	while (true) {
 		unsigned long ops;
@@ -118,23 +143,6 @@ void riscv_software_interrupt(void)
 	}
 }
 
-static void
-send_ipi_message(const struct cpumask *to_whom, enum ipi_message_type operation)
-{
-	int cpuid, hartid;
-	struct cpumask hartid_mask;
-
-	cpumask_clear(&hartid_mask);
-	mb();
-	for_each_cpu(cpuid, to_whom) {
-		set_bit(operation, &ipi_data[cpuid].bits);
-		hartid = cpuid_to_hartid_map(cpuid);
-		cpumask_set_cpu(hartid, &hartid_mask);
-	}
-	mb();
-	sbi_send_ipi(cpumask_bits(&hartid_mask));
-}
-
 static const char * const ipi_names[] = {
 	[IPI_RESCHEDULE]	= "Rescheduling interrupts",
 	[IPI_CALL_FUNC]		= "Function call interrupts",
@@ -156,12 +164,12 @@ void show_ipi_stats(struct seq_file *p, int prec)
 
 void arch_send_call_function_ipi_mask(struct cpumask *mask)
 {
-	send_ipi_message(mask, IPI_CALL_FUNC);
+	send_ipi_mask(mask, IPI_CALL_FUNC);
 }
 
 void arch_send_call_function_single_ipi(int cpu)
 {
-	send_ipi_message(cpumask_of(cpu), IPI_CALL_FUNC);
+	send_ipi_single(cpu, IPI_CALL_FUNC);
 }
 
 void smp_send_stop(void)
@@ -176,7 +184,7 @@ void smp_send_stop(void)
 
 		if (system_state <= SYSTEM_RUNNING)
 			pr_crit("SMP: stopping secondary CPUs\n");
-		send_ipi_message(&mask, IPI_CPU_STOP);
+		send_ipi_mask(&mask, IPI_CPU_STOP);
 	}
 
 	/* Wait up to one second for other CPUs to stop */
@@ -191,6 +199,5 @@ void smp_send_stop(void)
 
 void smp_send_reschedule(int cpu)
 {
-	send_ipi_message(cpumask_of(cpu), IPI_RESCHEDULE);
+	send_ipi_single(cpu, IPI_RESCHEDULE);
 }
-
-- 
2.20.1

