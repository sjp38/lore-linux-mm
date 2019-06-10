Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 383C2C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F026F2082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="E1yML8b2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F026F2082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 985886B0272; Mon, 10 Jun 2019 18:16:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 935B26B0273; Mon, 10 Jun 2019 18:16:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FF176B0274; Mon, 10 Jun 2019 18:16:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 488B36B0272
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:47 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d3so4842823pgc.9
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UEy/4Lyls0cszyUScQ4qCl6Em4CB1JokLTZUjPlbm8w=;
        b=FgYzN3bTt2jdAu4XvDpwQLBENzzuSpm9B9pXOJxipiFCStpi/qsSGhoJvHwdInqNV8
         DMJstN3lnPFF/lRVqi2m3VU/YkZ8SlGqVSVISbE64U5CGqX07UhhvGUGkU2UtnieuRO1
         IwnbmyhLnqbPf8JelGEJPylGEr0hrzeNmUPlNkDEdz1zc4u4OopngktDBemPB3/nPMwF
         Mzvh+6M+phtc2bHmQK2RuHVzfNhFZ/eeKihpSplMzRdVPXGiWj+J2jmkP8FB60SMWax0
         m+FWDgGVoIYcu2qo3sIUrSPa8bQbP9ECty0J04zCxt4IQlXTW8SJKQeCIAUtjQQUpYYq
         /rWw==
X-Gm-Message-State: APjAAAX5N19uXimxBOEDlsBHhF0ovqgY1i9MVNyXCwhaHCyYmx9hY3m0
	tG71UgUN2eMtK7APY4dr1TAqsYu3jwkGbLnBDPD3WAB+F7CnviqLtYZ0lFerzTcXn1v6itE/kV1
	mVyA+s/YQOsSy2oTfdnbC8fLaq7pW5Ivd88o1rVdLPGovWTv9JuJJuQvZbUUd3LY=
X-Received: by 2002:a17:902:a412:: with SMTP id p18mr4394641plq.105.1560205006934;
        Mon, 10 Jun 2019 15:16:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSrlnSMqGlmvYRDBMn4uFQfBhHCSSBjxHOSnFLQfxeMU+VOvQYTGPnmIVbASrH5A4qah8m
X-Received: by 2002:a17:902:a412:: with SMTP id p18mr4394597plq.105.1560205006268;
        Mon, 10 Jun 2019 15:16:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560205006; cv=none;
        d=google.com; s=arc-20160816;
        b=eq+MYYDvYkZKqvrojcYckhDasKtMZULngJhaZWyiZsATqqsnJR8pECDBb8XKdgSqSF
         pi/ZXUzBKrV4n+d8f2+didLrsW13PVW25XrCu2HHaodLyw23nOj8eQXGUFK6F+H0hxxV
         QYSE6F+bRIwWw9Dox54h4mxL5siCTpdyB7JtiC8PiBK0uWnRMTtmiQ+j4Gel0/sd2H/S
         W8cY+W8XNLTFxF7ZCcAldxPB470XDqi/OoTvqMzooRugiB2jub35xloaVsiWfVqFmvu3
         MP89IXhWguOPe4ecDZiwH0GDXlpP5kdG/FiCdVZPhsKf8OS4+LHssVfljuP900reC0Hi
         QkYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UEy/4Lyls0cszyUScQ4qCl6Em4CB1JokLTZUjPlbm8w=;
        b=Ax3gNYtxz+ciFf/zzpxdApDGtjZ4W90JcLlLzlf1yTOPyJPt5rgdXiRyTvNEkhDi+a
         tqvJw23qy20uD98hxY7FaWdKvgW+6Ag7JvweuD5bWxuqiJvY1ntLHLQYk9QB2Qh7nPYG
         9jCw/6ApwiO7BjGpDTPYrXroJlsou0pdhLRUV9mlLAopvdS/D65EMhTOd6wqnoPfPbuM
         D9RurHFaGYRgw+dlp+EobFfgm1f5FkQs7fO/hwbZmnz0GpfSLGGnjZUDn0NBOHg417K9
         NeQoMLo2uJCHgG1bdusntPSwhNgnppvMDirqLhTluYk1YFqc2W99cmNgh7uZzaJhdD/G
         sb5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E1yML8b2;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u17si3359000pfc.210.2019.06.10.15.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E1yML8b2;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=UEy/4Lyls0cszyUScQ4qCl6Em4CB1JokLTZUjPlbm8w=; b=E1yML8b29i76hIlU7NAyq0k3R9
	IlsAjrwqtrMV5rSvZIVjbksh4yLw8z9HPXyGXRzvqVeDniIJ/ypaeeTob7ufpi5ztS2cuoIDcH5O4
	hue0scRmZMTTwKa3+LP12tnFOxCj0/EbSj4GYGsYt2+nUSRmWOxBpfdbWcrn1MuQGX+E6WPn7zEig
	LItcuSFwwyPGSpjJPAOdMqxKU4o1BpaAt4bC8ZQn90KbVjoIzyixTM5ONrRIeproeDiwJ7HKgFffs
	e6sOlflVkQqvYHRWQWh7v4w1h5Su+R4f3Mgu34Ovom6EyZOgf6A3uFlETUFbJUBJR+JmUDnM7J0Eo
	iSptNjGg==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSan-00039t-W3; Mon, 10 Jun 2019 22:16:42 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 07/17] riscv: refactor the IPI code
Date: Tue, 11 Jun 2019 00:16:11 +0200
Message-Id: <20190610221621.10938-8-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190610221621.10938-1-hch@lst.de>
References: <20190610221621.10938-1-hch@lst.de>
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
index b2537ffa855c..91164204496c 100644
--- a/arch/riscv/kernel/smp.c
+++ b/arch/riscv/kernel/smp.c
@@ -89,13 +89,38 @@ static void ipi_stop(void)
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
@@ -129,23 +154,6 @@ void riscv_software_interrupt(void)
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
@@ -167,12 +175,12 @@ void show_ipi_stats(struct seq_file *p, int prec)
 
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
@@ -187,7 +195,7 @@ void smp_send_stop(void)
 
 		if (system_state <= SYSTEM_RUNNING)
 			pr_crit("SMP: stopping secondary CPUs\n");
-		send_ipi_message(&mask, IPI_CPU_STOP);
+		send_ipi_mask(&mask, IPI_CPU_STOP);
 	}
 
 	/* Wait up to one second for other CPUs to stop */
@@ -202,6 +210,5 @@ void smp_send_stop(void)
 
 void smp_send_reschedule(int cpu)
 {
-	send_ipi_message(cpumask_of(cpu), IPI_RESCHEDULE);
+	send_ipi_single(cpu, IPI_RESCHEDULE);
 }
-
-- 
2.20.1

