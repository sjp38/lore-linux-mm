Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05315C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A849523A9F
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="WdBT87pg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A849523A9F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BF4A6B000D; Sat,  1 Jun 2019 09:17:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3492D6B000E; Sat,  1 Jun 2019 09:17:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EA986B0010; Sat,  1 Jun 2019 09:17:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3A986B000D
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:17:35 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x5so9623367pfi.5
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:17:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9luxp6xqSTt2H1t9f1N166Q+JQj2PyWjHbTZSnkMdIc=;
        b=CaKjCAKkSeq1FL3hqqUjT7EW2RQP78TpilgsfIWZf9FSb367ooQ1DteMk7axvE+/XK
         dYSrlJOPqx68v0bWYnezT7XqCmuNvwtRn+T8FXVvdRluWH/YO0wZk70tVKtVU5pOXsY3
         v06aEq6VCCN+9+uGvSiBBxdcuA6GbdTWyL+E2V4GoYSQrTA5yZ6PiQDrLdMy6YtDdD3J
         e3VD8B08g7mGdsJYK5fuqtaQvwNBOoYci5q3fmwFr33wPuo4h8OfTnyVH/zIPGaVU90V
         qV4wuehSPib4Y23RLbY6VBQ+b8xDE5FdMwKhTkqqf79w+5Btdb6GztIccOGOKc/z/JCH
         BEtg==
X-Gm-Message-State: APjAAAWXenXVVpFl1OjiDD9WSlWiE1cfcFaO8c0KxF9HBMSKycmm+Ki7
	BJM4BJIMWYIIvnmy7Hyez8I5W0g3I+X+Q/vo7WGvE/vrPg2Y/pGM3s38KDDBB84vBzEcdMgkC17
	KK+sTf6qFzffm7ZGMYeYQGE1kLv+d2ktXBsYFnxZ0WXPwC3frQ2Tv2Vnzx6NOAb/UQA==
X-Received: by 2002:a17:902:9f94:: with SMTP id g20mr16585423plq.56.1559395055497;
        Sat, 01 Jun 2019 06:17:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwc5TOkonPZqKy7DFrRKv//resTcsVfnplmkrX/fu+wERHDuEpX6UobEW1hSBpRST2lC6x
X-Received: by 2002:a17:902:9f94:: with SMTP id g20mr16585341plq.56.1559395054752;
        Sat, 01 Jun 2019 06:17:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395054; cv=none;
        d=google.com; s=arc-20160816;
        b=hrnmIGQkcy5aAWlKmFhP5yUvxKv+mVlhZwZuXMi+wIGKzPNmGsj6oH5xLQtNMBr3xk
         F9fYSlSykwktT7KWL/gRFRZ8RzxuVa3C5uWiiJa+5BxNAaNyTOxXSI4s/cKTSrmwXptd
         wlL020cexuQTnKhNpKSYdU5joLGDu9rOkauUchFVDb66jCWB0uazFEY3jxNSkO9Ef66y
         z9ijLIchE/hD/Ec0sxSmZCjLSuSWVAh5HvUSKnt/fU5ejTk9b07oopBd7D4ITtT00w2f
         l78lu/PJhVD38oqVeFXrIMxSxHOzNzwC4RViDtC2S6wvh4n8FyiCA3pAvYn0BlZUNa/t
         Azgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=9luxp6xqSTt2H1t9f1N166Q+JQj2PyWjHbTZSnkMdIc=;
        b=aTf47d0uNxYQ8ABMHNLJ7Qx0PlZ5i47miPmBf0wywAHDNXkIYV9B4CVyTtbjhWV4Xv
         LJWtJ7jTl2mEvVDVAq6fh4ETx38e+kM/F4xDyXTGdVDmdboqbcQvPkS2CtdoJrj3kFnk
         BfuF0PDQhu0ayo0Wu0v76ZiDeuhT6yiVghmIl9ssQVRWUH+rTGbuizug3fq4voINYvaL
         Ba7sKimxPXGaDlTiwdngT/qcEIYoRWKgy2ESovxJ83/E7tUOmF4YljN1N8N77go2/iUt
         RN0fjd/usAMroME699jMXthmAfEldRohy6miJMjzQAfqLgkjP5F3rnyMzhxNwzApDJgG
         K77g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=WdBT87pg;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f13si10136242pgs.90.2019.06.01.06.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=WdBT87pg;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 38A8525F5A;
	Sat,  1 Jun 2019 13:17:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395054;
	bh=FSFoZTMt11iXc0aoK+/E7I+63GFkRN+cT3nCiArd59o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=WdBT87pg0UO5w1MqB8+z4+fAVpvvH1f/91WDmyZLQIH7xUwCxvlkBgwNbObVLTRQe
	 5lPZypnb312K9GYy6vDqflQRDvLkg19l8InDv5tFYopf1uWwoLTNRzmDJ+MVu0lEqh
	 8lWAAI22pjolklMNRrpkxMa3jC9SBfedVlcS5Fl8=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	Andy Lutomirski <luto@kernel.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Travis <mike.travis@hpe.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	Oscar Salvador <osalvador@suse.com>,
	Paul Mackerras <paulus@samba.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Rich Felker <dalias@libc.org>,
	Rob Herring <robh@kernel.org>,
	Stefan Agner <stefan@agner.ch>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tony Luck <tony.luck@intel.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 013/186] mm/memory_hotplug: release memory resource after arch_remove_memory()
Date: Sat,  1 Jun 2019 09:13:49 -0400
Message-Id: <20190601131653.24205-13-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: David Hildenbrand <david@redhat.com>

[ Upstream commit d9eb1417c77df7ce19abd2e41619e9dceccbdf2a ]

Patch series "mm/memory_hotplug: Better error handling when removing
memory", v1.

Error handling when removing memory is somewhat messed up right now.  Some
errors result in warnings, others are completely ignored.  Memory unplug
code can essentially not deal with errors properly as of now.
remove_memory() will never fail.

We have basically two choices:
1. Allow arch_remov_memory() and friends to fail, propagating errors via
   remove_memory(). Might be problematic (e.g. DIMMs consisting of multiple
   pieces added/removed separately).
2. Don't allow the functions to fail, handling errors in a nicer way.

It seems like most errors that can theoretically happen are really corner
cases and mostly theoretical (e.g.  "section not valid").  However e.g.
aborting removal of sections while all callers simply continue in case of
errors is not nice.

If we can gurantee that removal of memory always works (and WARN/skip in
case of theoretical errors so we can figure out what is going on), we can
go ahead and implement better error handling when adding memory.

E.g. via add_memory():

arch_add_memory()
ret = do_stuff()
if (ret) {
	arch_remove_memory();
	goto error;
}

Handling here that arch_remove_memory() might fail is basically
impossible.  So I suggest, let's avoid reporting errors while removing
memory, warning on theoretical errors instead and continuing instead of
aborting.

This patch (of 4):

__add_pages() doesn't add the memory resource, so __remove_pages()
shouldn't remove it.  Let's factor it out.  Especially as it is a special
case for memory used as system memory, added via add_memory() and friends.

We now remove the resource after removing the sections instead of doing it
the other way around.  I don't think this change is problematic.

add_memory()
	register memory resource
	arch_add_memory()

remove_memory
	arch_remove_memory()
	release memory resource

While at it, explain why we ignore errors and that it only happeny if
we remove memory in a different granularity as we added it.

[david@redhat.com: fix printk warning]
  Link: http://lkml.kernel.org/r/20190417120204.6997-1-david@redhat.com
Link: http://lkml.kernel.org/r/20190409100148.24703-2-david@redhat.com
Signed-off-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: Andrew Banman <andrew.banman@hpe.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mike Travis <mike.travis@hpe.com>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Rich Felker <dalias@libc.org>
Cc: Rob Herring <robh@kernel.org>
Cc: Stefan Agner <stefan@agner.ch>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 35 +++++++++++++++++++++--------------
 1 file changed, 21 insertions(+), 14 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b236069ff0d82..28587f2901090 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -561,20 +561,6 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	if (is_dev_zone(zone)) {
 		if (altmap)
 			map_offset = vmem_altmap_offset(altmap);
-	} else {
-		resource_size_t start, size;
-
-		start = phys_start_pfn << PAGE_SHIFT;
-		size = nr_pages * PAGE_SIZE;
-
-		ret = release_mem_region_adjustable(&iomem_resource, start,
-					size);
-		if (ret) {
-			resource_size_t endres = start + size - 1;
-
-			pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
-					&start, &endres, ret);
-		}
 	}
 
 	clear_zone_contiguous(zone);
@@ -1843,6 +1829,26 @@ void try_offline_node(int nid)
 }
 EXPORT_SYMBOL(try_offline_node);
 
+static void __release_memory_resource(resource_size_t start,
+				      resource_size_t size)
+{
+	int ret;
+
+	/*
+	 * When removing memory in the same granularity as it was added,
+	 * this function never fails. It might only fail if resources
+	 * have to be adjusted or split. We'll ignore the error, as
+	 * removing of memory cannot fail.
+	 */
+	ret = release_mem_region_adjustable(&iomem_resource, start, size);
+	if (ret) {
+		resource_size_t endres = start + size - 1;
+
+		pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
+			&start, &endres, ret);
+	}
+}
+
 /**
  * remove_memory
  * @nid: the node ID
@@ -1877,6 +1883,7 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 	memblock_remove(start, size);
 
 	arch_remove_memory(nid, start, size, NULL);
+	__release_memory_resource(start, size);
 
 	try_offline_node(nid);
 
-- 
2.20.1

