Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 926056B0260
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h16so16849492wrf.0
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 10:45:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z24si5232901edc.186.2017.09.27.10.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 10:45:16 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8RHi0jA126118
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:14 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2d8fpmknff-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:14 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 27 Sep 2017 18:45:13 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH 3/3] lsmem/chmem: add memory zone awareness to bash-completion
Date: Wed, 27 Sep 2017 19:44:46 +0200
In-Reply-To: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
References: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
Message-Id: <20170927174446.20459-4-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: util-linux@vger.kernel.org, Karel Zak <kzak@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andre Wild <wild@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

From: Andre Wild <wild@linux.vnet.ibm.com>

This patch extends the valid --output values with ZONES for the
lsmem bash-completion, and adds the --zone option for the chmem
bash-completion.

Signed-off-by: Andre Wild <wild@linux.vnet.ibm.com>
Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 bash-completion/chmem | 1 +
 bash-completion/lsmem | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/bash-completion/chmem b/bash-completion/chmem
index 00b870dbd90d..3e3af87acaa5 100644
--- a/bash-completion/chmem
+++ b/bash-completion/chmem
@@ -16,6 +16,7 @@ _chmem_module()
 				--disable
 				--blocks
 				--verbose
+				--zone
 				--help
 				--version
 			"
diff --git a/bash-completion/lsmem b/bash-completion/lsmem
index 8f7a46ec30af..9aa124569d53 100644
--- a/bash-completion/lsmem
+++ b/bash-completion/lsmem
@@ -9,7 +9,7 @@ _lsmem_module()
 			local prefix realcur OUTPUT_ALL OUTPUT
 			realcur="${cur##*,}"
 			prefix="${cur%$realcur}"
-			OUTPUT_ALL='RANGE SIZE STATE REMOVABLE BLOCK NODE'
+			OUTPUT_ALL='RANGE SIZE STATE REMOVABLE BLOCK NODE ZONES'
 			for WORD in $OUTPUT_ALL; do
 				if ! [[ $prefix == *"$WORD"* ]]; then
 					OUTPUT="$WORD ${OUTPUT:-""}"
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
