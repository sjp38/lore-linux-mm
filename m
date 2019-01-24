Return-Path: <SRS0=9gyo=QA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65AF0C282C6
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 23:21:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 307B6218A2
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 23:21:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 307B6218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8CBB8E00AF; Thu, 24 Jan 2019 18:21:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3ABA8E00AC; Thu, 24 Jan 2019 18:21:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B93E8E00AF; Thu, 24 Jan 2019 18:21:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4AEC48E00AC
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:21:55 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o17so5035381pgi.14
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:21:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=mIxy0xdlDeGCgrGHdCCkB4khySDD4hZUeK1rlRQNXm4=;
        b=f9qjpzExv9ulFeTL5heNF7Jzjt/XLUpFTISq5FbDnFvrJaIjIpJ9VBvGO9wQ9dQ6lW
         UbR4j53FsFSx0cYdVUZp+KRQYDo+U5TPl6ebAPsl8HpsKgc3aJPHJeTQqrR1lAaQsrRY
         9gj70YvwJLbjNQGClhZiemXIQ6W7w/hJowxt3XoMUBS/lETp0eIIc7R9J8bwd0QDtajR
         /MI0plTEPcHKfdJ6tmrF4rLX+tMHUa48fhNPmLpFfpk9Ev7AztyJ3Ic+7WKIqdKBOL+p
         fGRrsgB8Ygepm55/yyY2gyxM+HhOyHaYThfoz5WT8cpTYWDblYaNjLcn0a6akeoXsBz4
         ZIDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUuke+1XIIDHaF2uI9IFGrqtynln23c6XRQyjxP9j/biOMZeIheiAr
	8rNhlX0DPbIoOz1v052lP0/iPGH2Rr+TQxaCHFiVDl/21xlIE30mEvsO7MEsCSb7Bzg0dj6soBQ
	V2qnXy7bEC0NDd0HWO3CLoiKkMMoWJAXnNL0vGTIfUQ0EmVmfAOnWEpf4KA119Y17Mg==
X-Received: by 2002:a17:902:830a:: with SMTP id bd10mr8531847plb.321.1548372114951;
        Thu, 24 Jan 2019 15:21:54 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4bq6I2DVCDv3Yg9HqZJuqDTFfV6xDkreQLJQjAfhxN0WxOmI6yWga+Rf7x1A4x/TSLURpc
X-Received: by 2002:a17:902:830a:: with SMTP id bd10mr8531801plb.321.1548372114168;
        Thu, 24 Jan 2019 15:21:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548372114; cv=none;
        d=google.com; s=arc-20160816;
        b=YTYMUprqw/g7jk0ehJFEVfmGv0efGrk1q2mswPYamOKIyDGMRntQiDLaFxy5m0LKbc
         CQDFtJ+OL80Pl0MWfzufmKD/CuHqZiNf+lxovTjIAt8Rt538CLDBJ/a7pKTvh36QX8bU
         ifnrz58nj4CnaEdxGYJzDpOjkwyprmR6DeJtozV18t2KSobNb5YZl7IWukVTCr3LtNX0
         qhPep4PD0hefrMvzhpTkfKmr8KK0rE6QQg1dHElSk9094PI9aENgn4B0l71tLTnRkgvI
         zMLz9Qw3+bWjIzh7CAs3i/3NPLFs1/laGv7IMSTO6YIvGzUTrv2PMaobRiQZlN3BzWOF
         PqYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=mIxy0xdlDeGCgrGHdCCkB4khySDD4hZUeK1rlRQNXm4=;
        b=lFe4pPuIjGCCRbPbOuzZZP6l2iQIzl+jp/5ZiO3XUmWImFe/KoiVuAIdMfPvxsO8GQ
         nkmE+/uG3OlXNpXs126r8qGpnG3xJlYn6wpe8VL92pU9itUWW1kLBh/pCT89taHMp8B2
         i0an59UfN/J58w3Rrc+0pbLX/5MX4AVZbN5DGEmy7IYkDbMhmsQE+hxdVzWpEV7t5V7V
         KOd0gytBGAU9C46f8PGi7wF3W2Fsy0RJXKbp37KSyLeroxBu1fwrNbjSrTbwYiwyayqS
         GsI9gGZxBpkebLQ0Uh357fZ36aM92FnSnrIAz+HKYB11zOu5DAbWEGiyeu2r6/zyFRnd
         i94Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q24si23382216pls.325.2019.01.24.15.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:21:54 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jan 2019 15:21:53 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,518,1539673200"; 
   d="scan'208";a="294207413"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga005.jf.intel.com with ESMTP; 24 Jan 2019 15:21:53 -0800
Subject: [PATCH 2/5] mm/resource: move HMM pr_debug() deeper into resource code
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,jglisse@redhat.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 24 Jan 2019 15:14:44 -0800
References: <20190124231441.37A4A305@viggo.jf.intel.com>
In-Reply-To: <20190124231441.37A4A305@viggo.jf.intel.com>
Message-Id: <20190124231444.38182DD8@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190124231444.4simOTT7mo6ZuiW2sHytY5rmOxM8BuqcYJk1xnPDZzo@z>


From: Dave Hansen <dave.hansen@linux.intel.com>

HMM consumes physical address space for its own use, even
though nothing is mapped or accessible there.  It uses a
special resource description (IORES_DESC_DEVICE_PRIVATE_MEMORY)
to uniquely identify these areas.

When HMM consumes address space, it makes a best guess about
what to consume.  However, it is possible that a future memory
or device hotplug can collide with the reserved area.  In the
case of these conflicts, there is an error message in
register_memory_resource().

Later patches in this series move register_memory_resource()
from using request_resource_conflict() to __request_region().
Unfortunately, __request_region() does not return the conflict
like the previous function did, which makes it impossible to
check for IORES_DESC_DEVICE_PRIVATE_MEMORY in a conflicting
resource.

Instead of warning in register_memory_resource(), move the
check into the core resource code itself (__request_region())
where the conflicting resource _is_ available.  This has the
added bonus of producing a warning in case of HMM conflicts
with devices *or* RAM address space, as opposed to the RAM-
only warnings that were there previously.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
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
Cc: Jerome Glisse <jglisse@redhat.com>
---

 b/kernel/resource.c   |   10 ++++++++++
 b/mm/memory_hotplug.c |    5 -----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff -puN kernel/resource.c~move-request_region-check kernel/resource.c
--- a/kernel/resource.c~move-request_region-check	2019-01-24 15:13:14.453199539 -0800
+++ b/kernel/resource.c	2019-01-24 15:13:14.458199539 -0800
@@ -1123,6 +1123,16 @@ struct resource * __request_region(struc
 		conflict = __request_resource(parent, res);
 		if (!conflict)
 			break;
+		/*
+		 * mm/hmm.c reserves physical addresses which then
+		 * become unavailable to other users.  Conflicts are
+		 * not expected.  Be verbose if one is encountered.
+		 */
+		if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
+			pr_debug("Resource conflict with unaddressable "
+				 "device memory at %#010llx !\n",
+				 (unsigned long long)start);
+		}
 		if (conflict != parent) {
 			if (!(conflict->flags & IORESOURCE_BUSY)) {
 				parent = conflict;
diff -puN mm/memory_hotplug.c~move-request_region-check mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~move-request_region-check	2019-01-24 15:13:14.455199539 -0800
+++ b/mm/memory_hotplug.c	2019-01-24 15:13:14.459199539 -0800
@@ -109,11 +109,6 @@ static struct resource *register_memory_
 	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	conflict =  request_resource_conflict(&iomem_resource, res);
 	if (conflict) {
-		if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
-			pr_debug("Device unaddressable memory block "
-				 "memory hotplug at %#010llx !\n",
-				 (unsigned long long)start);
-		}
 		pr_debug("System RAM resource %pR cannot be added\n", res);
 		kfree(res);
 		return ERR_PTR(-EEXIST);
_

