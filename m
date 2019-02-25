Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 149FDC10F16
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D756B2084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D756B2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E65A58E000D; Mon, 25 Feb 2019 14:02:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3D718E0004; Mon, 25 Feb 2019 14:02:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6C1C8E000D; Mon, 25 Feb 2019 14:02:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83B0A8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:02:44 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id go14so7946197plb.0
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:02:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=wTpfmsZuic2HvDF5hoBzln3PVoDtdFMJRGlcBqYIJwE=;
        b=KAHRIWJ41Y6MiX/1t5jzj5GJVdkdnxHXkxDi22D1Oa5DTpQ9dNtBDMQDhkt4AOjCc7
         cCy93K6bnLsAuysadCqSsJHooDlePGoUzr4SnSoHl+frqgl+Fez09X7ig6r1EqFlS0KO
         wy7h1wvmJNLMiJWqyh8pVCzyJLeNR2M9osnfTnxAHMrNvc/yEr/bJ38XzkBilJ7rRKek
         tMZX4cnG98T1Uf21RkoLTRFFivDs4omzQjdR5qo+ovfgsZ98z9z7ucto1/OMgcnm395L
         bKIgFZ9inW/cD72H/P9tgcsrYNATWi3H/jYPbP991zoB+DOYbQTDUIq7W9Mds40NW6ii
         bEgg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYaqh++waSkj1lknTbSQ2P0OpX+JQNiH1Y2m1nYZqHjHXOK0nY6
	/B3tZyBe5m3veAMELk4oltWjLyqvmeXGm0o6Yi6uosuCGJ3mDrtm0zTgqFEe1ZicUDxz0paFdZN
	cGWNS1WI+TmGpDzB/IVfRqwIJ8OKGeUPX/rVJhe/uLMBe5BpXGJ/CYXOAHXyU1VDEuw==
X-Received: by 2002:a65:6549:: with SMTP id a9mr19783355pgw.21.1551121364175;
        Mon, 25 Feb 2019 11:02:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBjq7r6yh5vxOcKLxJzLtBKvpSEsV89M19ogwVd7ekIIu5uTD1Vm5yWzf/WDbgaYwBFGe0
X-Received: by 2002:a65:6549:: with SMTP id a9mr19783294pgw.21.1551121363405;
        Mon, 25 Feb 2019 11:02:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551121363; cv=none;
        d=google.com; s=arc-20160816;
        b=xJUeiuB1T7fC/Zyq3CB919zjxxTnU1xgaz6+eBYsBafdGeuTmMdjnJzAKMklH+vvYV
         BSWMZZV3CpvE2i0qCMhRSPNkhcf4/Yu9bBs90LLC/BEHiMj9uptuSYmlLQQ3AjvPS5VW
         QlBKrBJ8gnUFgdkIJ0UOOywOOKoNdw6Efg0qcnJ1Z6h2VY2wgGDaU7yvMUBrkTt3IFDH
         hZRLHDkl3scRLQ6vCC+ULGm0BhXghZyf/L8QWiXy4Q32mSRT3GAVtHUMG+4IMuQaXp+B
         +e9lad3WIpU2cbRE1jRXInq8Uvdpro+6xsAHsrVPSum3/ywowVdAE4gcJylSP+jmlsxI
         Izsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=wTpfmsZuic2HvDF5hoBzln3PVoDtdFMJRGlcBqYIJwE=;
        b=KDG2YUxJjWV3pZNe/RZJqcHfjUMFZQu6NEubJBhQQ696r+WKEcYsttCBlhhAAShBU8
         ySIqfy45gGx45mDi0TbAmxK+NwyRohArRLwPvn5eLW5svktQurlb5uJ59NZGwlbHFnKL
         Ltp5K+Fh6OEG+ywTdktS2Fnd5UOlvMOMJk85K6keErG58DFRFyopSIenVTgMEPDmOu2s
         AUmNyL7DVMlo/XCEAcjNMkHLRL6HBhB5SZ7GUweoQ4S/0nbpEBMhM5BHukrQ39zfN+JG
         /09S+zgM4Vls00gClU9R5LTsdgLu761RcTtsQnNh7ncIByUaXICxuMhw70MiIRoPFfuI
         oDXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a89si10434099pla.362.2019.02.25.11.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 11:02:43 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 11:02:42 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,412,1544515200"; 
   d="scan'208";a="118984325"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga006.jf.intel.com with ESMTP; 25 Feb 2019 11:02:42 -0800
Subject: [PATCH 4/5] mm/resource: let walk_system_ram_range() search child resources
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,keith.busch@intel.com,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de,jglisse@redhat.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 25 Feb 2019 10:57:38 -0800
References: <20190225185727.BCBD768C@viggo.jf.intel.com>
In-Reply-To: <20190225185727.BCBD768C@viggo.jf.intel.com>
Message-Id: <20190225185738.F6C24E62@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


From: Dave Hansen <dave.hansen@linux.intel.com>

In the process of onlining memory, we use walk_system_ram_range()
to find the actual RAM areas inside of the area being onlined.

However, it currently only finds memory resources which are
"top-level" iomem_resources.  Children are not currently
searched which causes it to skip System RAM in areas like this
(in the format of /proc/iomem):

a0000000-bfffffff : Persistent Memory (legacy)
  a0000000-afffffff : System RAM

Changing the true->false here allows children to be searched
as well.  We need this because we add a new "System RAM"
resource underneath the "persistent memory" resource when
we use persistent memory in a volatile mode.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Jerome Glisse <jglisse@redhat.com>
---

 b/kernel/resource.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff -puN kernel/resource.c~mm-walk_system_ram_range-search-child-resources kernel/resource.c
--- a/kernel/resource.c~mm-walk_system_ram_range-search-child-resources	2019-02-25 10:56:50.750908026 -0800
+++ b/kernel/resource.c	2019-02-25 10:56:50.754908026 -0800
@@ -454,6 +454,9 @@ int walk_mem_res(u64 start, u64 end, voi
  * This function calls the @func callback against all memory ranges of type
  * System RAM which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
  * It is to be used only for System RAM.
+ *
+ * This will find System RAM ranges that are children of top-level resources
+ * in addition to top-level System RAM resources.
  */
 int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 			  void *arg, int (*func)(unsigned long, unsigned long, void *))
@@ -469,7 +472,7 @@ int walk_system_ram_range(unsigned long
 	flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	while (start < end &&
 	       !find_next_iomem_res(start, end, flags, IORES_DESC_NONE,
-				    true, &res)) {
+				    false, &res)) {
 		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		end_pfn = (res.end + 1) >> PAGE_SHIFT;
 		if (end_pfn > pfn)
_

