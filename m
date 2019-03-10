Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1037AC43381
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 01:19:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA9A1206BA
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 01:19:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EWYTqV2O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA9A1206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D5468E0004; Sat,  9 Mar 2019 20:19:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05B8B8E0002; Sat,  9 Mar 2019 20:19:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3DD38E0004; Sat,  9 Mar 2019 20:19:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id B8A408E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 20:19:12 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id v125so1633327itc.4
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 17:19:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=0N1MhcRbdixhLcojGjz1JbD9gYvKsU3sALAMDz5L+zQ=;
        b=k81MN8etVPllCQ2uVs9k9ZjyBQXGAy2c0Brtvji/bJ37h9VCuZNmJxcO8V6ZwQ+VUT
         6Pz5UWrXDc/HRPfJyJozNAUqKLKEof7KtRe9hnMJP1APSx1ko0VBv1n1umzcrop2YQjX
         dRbpOk//WXWGCG8/IJeIcbSSMazmA9xyrrzZlOLvp4yAObcSM+10IzDp9Y/cwn7ij5ic
         CPEMHf9YdI/F8nVPiAOh+kiUZhYZTEBzR+3S1Wi+BZom0sox0eq11No0F/RNscB71oXc
         V62nu9VV0EyOrsD8wy7C51WFxgtLdNJWKTUVxAKBmRqGHDfG05RfGCrVyCWeVe/3Nd8g
         EHCQ==
X-Gm-Message-State: APjAAAVszuVKz0/9u+8qYFM3S2Xcba4RdCKVf8MaVC+YV51wwSrQIccB
	fCh7gry4ZysaQAwUcokUG/KO6jAIa5qqjjvE6adGtV3tL1XpieocMqZAy+b2T95X6V45TksmxV/
	kCI7rEUbUsE+7ENzuXTeqVveSoV6tcJiEWeG8NVfVYNdKJ9Imqma3uNbtSsUKVM/iOnbNjaTpsX
	DwUqW4QyFnJyjwIGtJZ7phWffXDuXUu5h6LGWvq2Z1aC5Xj6l3PSnV2tDYDsdSjRKsMnTkiVK8X
	3yCE9FJoGSZPQPUCx2ElOuIDGhPFJKTUCIUCXjQIrPZqAlXD+LUbAIEw0DD1A76i3YlvviA85j8
	+//KJ2tcZiLJsCIE+ev2EwJ+fXphG/CXjpICQ2S7k2MwcyfoQlEn7z3ktjXYgsCDgBZyyrXN7fM
	x
X-Received: by 2002:a24:4741:: with SMTP id t62mr11675516itb.110.1552180752412;
        Sat, 09 Mar 2019 17:19:12 -0800 (PST)
X-Received: by 2002:a24:4741:: with SMTP id t62mr11675500itb.110.1552180751461;
        Sat, 09 Mar 2019 17:19:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552180751; cv=none;
        d=google.com; s=arc-20160816;
        b=N9/g3fbL+5TAsA4pzCunS/qAh/9REoF2A/CnoYQgZ/y6t60uottcGXgC3dZ7UJ+66V
         ZGpyN4ybp0nfsL1JhyIyitufOuIcCGsxrZhwhVElyjkJ6Ts5HFniV2GK18pNQS+gtlZB
         PE4iVZ2Li4zoSfgt4T0tv1eXsqfqwhUp0GrE1kg7aaPqjCAAMGTJXn37rJDXT3QWG1Vt
         3SULu1lTR88M3DYeZvc9B8JU4sR0Pjje5FawOJPhnLRniJGrp48M/iDr094mYVIn2peG
         jUPL7K2EQIHTqaZeSXGYR7OlFUQ8oo8BbnjNiNdN1VepAZAP58r6hsYxbeaFGGjh7kAk
         1BzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=0N1MhcRbdixhLcojGjz1JbD9gYvKsU3sALAMDz5L+zQ=;
        b=YAyK+chjBOFyhvCo1e8jnmAj6IijOfcirjVRymX1/08a0C3fCv0vfSqzPJ39aBHEz6
         D2yUPKzirPrq0HujjMygYh4mDYJGHc1o3+KNwoBvYwsnDlpnjG409/TEekFzAehgQ8AP
         3Rch3xLn4fq38IshKAimWgpajAWYWeJzKQLXJ7W3VMS8DUbaJIS+JxasgSzIfDUEssz/
         E1j9AQ12dnZEOMUya4uC0N2xuJG1fF7erq/P3d6CYRicUkWPeoWSZzzMie2HXsJij/i4
         XSR3XJgG60vj2ZcsJTrc5jSKZP20UU7qMYlce1/j+Ev3ZwvMwu/H1HnuhFpAaZD7QqUv
         fG6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EWYTqV2O;
       spf=pass (google.com: domain of 3d2aexaykcnyqmr92g8gg8d6.4gedafmp-eecn24c.gj8@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3D2aEXAYKCNYQMR92G8GG8D6.4GEDAFMP-EECN24C.GJ8@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h12sor20043965itb.29.2019.03.09.17.19.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Mar 2019 17:19:11 -0800 (PST)
Received-SPF: pass (google.com: domain of 3d2aexaykcnyqmr92g8gg8d6.4gedafmp-eecn24c.gj8@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EWYTqV2O;
       spf=pass (google.com: domain of 3d2aexaykcnyqmr92g8gg8d6.4gedafmp-eecn24c.gj8@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3D2aEXAYKCNYQMR92G8GG8D6.4GEDAFMP-EECN24C.GJ8@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=0N1MhcRbdixhLcojGjz1JbD9gYvKsU3sALAMDz5L+zQ=;
        b=EWYTqV2O2kn2zhIWcI3s1gmgxz1dXGxzOHPenWe89TDG4/8BxGz8vuObzzBtnXc8zn
         NjXgLS8HuTTvLpauBCevcESBrWxGSqM9g2cj56V1iqJmzZDUO9nPVoyciLxC6LzDzH3U
         UAbWy3JQJsk1VZSs7Nxw+1zz0XJAMe8cN4BhnZx3ojFoUW9IXD08xH/BzV3Tkwg0x1zk
         tnLSBiVVRYxYX+0fi4J0uoTiOugYrTudSji/00Whuzv81nFYtjnqB1W/h8Lc8kqO0L/m
         HU7+E5jphyonX4mohg03eaaVwiXnE+eC/FU8adSSlDYySBz4Y1BEqgHFtTl1zOHcicpu
         MlLg==
X-Google-Smtp-Source: APXvYqxi62oUXl8WHRUPEaV20EFaBbDZc8udY7BAs1+oaagWSJIk8olRNZ0zRHkcRKgD12OX84VO25JPVVo=
X-Received: by 2002:a24:cd07:: with SMTP id l7mr17617268itg.22.1552180751250;
 Sat, 09 Mar 2019 17:19:11 -0800 (PST)
Date: Sat,  9 Mar 2019 18:19:05 -0700
In-Reply-To: <20190310011906.254635-1-yuzhao@google.com>
Message-Id: <20190310011906.254635-2-yuzhao@google.com>
Mime-Version: 1.0
References: <20190218231319.178224-1-yuzhao@google.com> <20190310011906.254635-1-yuzhao@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v3 2/3] arm64: mm: don't call page table ctors for init_mm
From: Yu Zhao <yuzhao@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>, 
	Peter Zijlstra <peterz@infradead.org>, Joel Fernandes <joel@joelfernandes.org>, 
	"Kirill A . Shutemov" <kirill@shutemov.name>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Chintan Pandya <cpandya@codeaurora.org>, Jun Yao <yaojun8558363@gmail.com>, 
	Laura Abbott <labbott@redhat.com>, linux-arm-kernel@lists.infradead.org, 
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

init_mm doesn't require page table lock to be initialized at
any level. Add a separate page table allocator for it, and the
new one skips page table ctors.

The ctors allocate memory when ALLOC_SPLIT_PTLOCKS is set. Not
calling them avoids memory leak in case we call pte_free_kernel()
on init_mm.

Acked-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 arch/arm64/mm/mmu.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index f704b291f2c5..d1dc2a2777aa 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -370,6 +370,16 @@ static void __create_pgd_mapping(pgd_t *pgdir, phys_addr_t phys,
 	} while (pgdp++, addr = next, addr != end);
 }
 
+static phys_addr_t pgd_kernel_pgtable_alloc(int shift)
+{
+	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
+	BUG_ON(!ptr);
+
+	/* Ensure the zeroed page is visible to the page table walker */
+	dsb(ishst);
+	return __pa(ptr);
+}
+
 static phys_addr_t pgd_pgtable_alloc(int shift)
 {
 	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
@@ -594,7 +604,7 @@ static int __init map_entry_trampoline(void)
 	/* Map only the text into the trampoline page table */
 	memset(tramp_pg_dir, 0, PGD_SIZE);
 	__create_pgd_mapping(tramp_pg_dir, pa_start, TRAMP_VALIAS, PAGE_SIZE,
-			     prot, pgd_pgtable_alloc, 0);
+			     prot, pgd_kernel_pgtable_alloc, 0);
 
 	/* Map both the text and data into the kernel page table */
 	__set_fixmap(FIX_ENTRY_TRAMP_TEXT, pa_start, prot);
@@ -1070,7 +1080,8 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
 
 	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
-			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
+			     size, PAGE_KERNEL, pgd_kernel_pgtable_alloc,
+			     flags);
 
 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
 			   altmap, want_memblock);
-- 
2.21.0.360.g471c308f928-goog

