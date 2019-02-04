Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 395D1C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:15:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB1E72175B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:15:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oJsYf7z3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB1E72175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8870A8E004F; Mon,  4 Feb 2019 13:15:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8668D8E001C; Mon,  4 Feb 2019 13:15:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 772E88E004F; Mon,  4 Feb 2019 13:15:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 384808E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 13:15:43 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id h10so452917plk.12
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 10:15:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=zqElbD91wN7xrII3yrqdT2po60YKbiGuJ5EuHOboq08=;
        b=Jk6ja96yxRte8pIdsHAQkbZeTqr4Tuy/z1Vqb29QzNOGW6JNihRrt4vQ4z0DUgEEWY
         lC1rZxKRT4chNOB0WVg6pjL/5saS5LQr7ZvaMCXe6+86s/Jpdkz/fdgyuxcp3BZzp8k+
         /eMVz1w2IMxgp9rUWKkVVRVJzzo/FxwRp0PcJAZNn6YyaG1M10SKE5EjNDTWzJx1FQnn
         KHEP7TTQOG5nTfMxKcM0Sw6x+3yIqTJPyw0MyxMHYG00peoHZ8M3xl0mEy6/SVGhUagu
         8RdpkKDJ7nPIDLM6RAOoRNn2iX1ObQMcfRJhWh1A+hKX1mwReZ/RFGQv1fX2r3M4x/eH
         ECdw==
X-Gm-Message-State: AHQUAub6bm8p/bFZlKlon/Wd3KkQ1UuJsLXHe83YebZgxmKNkltgSpKq
	s3qA0YZzoBrPUXfBRdbvYg/2nnt/RJ4K7IGGQqfGyt5T0zCjnU0DI0P0PngxHrBKPJ/344JYGNK
	EIEOW0zhzNVhzy9qH2rg+7h7KZn0aJo9m3VyZ8FmCagzAP3YIAXP7YJ1b/AacGw3qavnTlAUBcv
	+YArYP+JWb5ZISVk7EiOo3T7GNf8VsB9XghJ6TaPO5WsstVYeo5MD5bAUzngbdPBwhWAOKpHwhY
	tLFxO409J+Th3HgUmXkIaP//EEVtnme0pI38VHr5j0fdylQ//pGcuZuOesFJa6IoaOTrcKdGDal
	rv4T60TTgjPMnzueT91VlUIy+EK6u8A3jm7pBe/DI08ArBjjZwJsI63hH8enI6q5k/pmnS/Ylsk
	F
X-Received: by 2002:a17:902:5601:: with SMTP id h1mr722079pli.160.1549304142708;
        Mon, 04 Feb 2019 10:15:42 -0800 (PST)
X-Received: by 2002:a17:902:5601:: with SMTP id h1mr722008pli.160.1549304141919;
        Mon, 04 Feb 2019 10:15:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549304141; cv=none;
        d=google.com; s=arc-20160816;
        b=IBiQAdfOQTpWl8ZMWfLwckbB2G9rYR9n5Exc9gZ9UDdSCndjkccIuuMmPW2nfdhcql
         Bi/DWvPBCpaVz8u07ilffDWyPz0xtwHMmKvPA8KnRvN7+hyc+PCDSN5xDSzO7CNMsEx4
         MTxxn1XslIrb9EluMoQ0APWBsQso/WCTMe7KDaIvR9HfOe2BSemnG7DBNo+dfdwFmWaM
         pkXk+EKc/eVISfnM+QG1WbsJh4aRN4lvlGRMt6EoGs0cYwZ0HfEuGKJ7qmRFF8syX3bt
         n49GPt+SVzzN0F+KDrdO11yHAo4+ljR4ZGxjH0/LHQ/F37v/YIlga7vxbpDKeYP0fVxA
         9lOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=zqElbD91wN7xrII3yrqdT2po60YKbiGuJ5EuHOboq08=;
        b=Gq10teCUIbXBWMSyXYAOdHOpLYFVIyjg1s5kjx+CZwNoMdmuf+PUa8tN7LaIH8yO+y
         ZVR/JhAbCT2kPzX6WG7+fo6X1AIG1ocW3N4LdY2kWI/C95kTBrabjXh3A7FBcKLoGXvV
         2lgTmXj90TpVaJOudKYq35ZolM6A+WGAyPluz3RL7kyYXKP+E/ifeK9Ov94hztKPrFem
         I9AB/sbA8PR/vBqmxUFtmIYDMJEdTE3CSA7/cA5ALsSqUYD6fmZcdSiS1GG8pusLNJB/
         zLOO5d3hVOLMu7tAzyy4w58NUmEaflyxMVtaNUlsCxpEckD0NDnRKOIgpDMumgyCoI9c
         /ZSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oJsYf7z3;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o23sor1340154pgv.0.2019.02.04.10.15.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 10:15:41 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oJsYf7z3;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=zqElbD91wN7xrII3yrqdT2po60YKbiGuJ5EuHOboq08=;
        b=oJsYf7z38AP8TbCH80dOcCkJYlGDdhpEscQ3nBiPGAezSpQoznfn6yaatFIh56rLa3
         WQTC59TkQ38+viuHQYO8ZTHXdI+ikg6haVJUBIfi65J1jh7YFOQScPeFfZn5FdLIwwV1
         HQBqxVYcgT/LNtaebjn1fviZ+IgZBpZybIhLxGWy4QMZkk8/ERcgCeCm1h0Ahhp0HBSL
         ojLR6pytSqLpez0vfIpiHCesbcI1La8NGXWRe7x6NeiEsm8412Xo098elaZawQ0pGk05
         5ytGec+2Ioqy0lGzOd4BXBHFOLC6p+IG7quU66Y9Uh+PJMntM5b7DnSKxSFW0Y1aRGXF
         smjA==
X-Google-Smtp-Source: AHgI3Ia491NQopE8fziC0IJZOVG35rTaJ4DGuP8qMsPV/GoMoreeKpaQJ7srkoR5qCHTRvCiosG1aw==
X-Received: by 2002:a63:2bc4:: with SMTP id r187mr615506pgr.306.1549304141567;
        Mon, 04 Feb 2019 10:15:41 -0800 (PST)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id v89sm1323954pfk.12.2019.02.04.10.15.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 10:15:41 -0800 (PST)
Subject: [RFC PATCH 1/4] madvise: Expose ability to set dontneed from kernel
From: Alexander Duyck <alexander.duyck@gmail.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
Date: Mon, 04 Feb 2019 10:15:40 -0800
Message-ID: <20190204181540.12095.87973.stgit@localhost.localdomain>
In-Reply-To: <20190204181118.12095.38300.stgit@localhost.localdomain>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

In order to enable a KVM hypervisor to notify the host that a guest has
freed its pages we will need to have a mechanism to update the virtual
memory associated with the guest. In order to expose this functionality I
am adding a new function do_madvise_dontneed that can be used to indicate
a region that a given VM is done with.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mm.h |    2 ++
 mm/madvise.c       |   13 ++++++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e04396375cf9..eb668a5b4b4f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2840,5 +2840,7 @@ static inline bool page_is_guard(struct page *page)
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+int do_madvise_dontneed(unsigned long start, size_t len_in);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/mm/madvise.c b/mm/madvise.c
index 21a7881a2db4..8730f7e0081a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -799,7 +799,7 @@ static int madvise_inject_error(int behavior,
  *  -EBADF  - map exists, but area maps something that isn't a file.
  *  -EAGAIN - a kernel resource was temporarily unavailable.
  */
-SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
+static int do_madvise(unsigned long start, size_t len_in, int behavior)
 {
 	unsigned long end, tmp;
 	struct vm_area_struct *vma, *prev;
@@ -894,3 +894,14 @@ static int madvise_inject_error(int behavior,
 
 	return error;
 }
+
+SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
+{
+	return do_madvise(start, len_in, behavior);
+}
+
+int do_madvise_dontneed(unsigned long start, size_t len_in)
+{
+	return do_madvise(start, len_in, MADV_DONTNEED);
+}
+EXPORT_SYMBOL_GPL(do_madvise_dontneed);

