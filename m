Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB254C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:53:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC66D20665
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:53:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC66D20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 032AB6B000A; Tue, 25 Jun 2019 03:53:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFEB28E0003; Tue, 25 Jun 2019 03:53:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEE228E0002; Tue, 25 Jun 2019 03:53:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 913A16B000A
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:53:12 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f19so24367366edv.16
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:53:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=pOYCJ3wCl+5Aq16br5xzf6IifgjC4BiDEDrEzJSV9Ig=;
        b=QBZB3ioZAVTlg66yX/siWfU6FT0AorVOSIFZflvIQQ4Bb/4IG5Y4SdqXBNRN0YTs0X
         PVqchoLTmcTfYH1fUp8z2g0uU64tqwA19RSfnvnA+OQQUeUcW7fjTGmu3NY5pjse0z3r
         oBM8yjxK5N9l67d1zUYgreqrO2KP1USByReHyHVJEYUGqKeeSQqorOaSH47+BodxyDo3
         tutL6iuIufBmVHY5QhuXOySyd4/Uczwv84A4TIK+t3jr2RAuXpcTizYvW+z7B9fqDL/T
         ca7EXPWV+d8wPBPnroT0TYAH6ldo0HksjkUg4GQDHI2YnyCIECWi/+TbZzDXRkcR1nGp
         BBog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVrsIxKGMW2HIYPbGNUmwAEILx2kBS82/UlWTsNgwWBZ/9UsMry
	H3UI460CzbHxoDz7KTVGartuAotnpjVoEHm9yposT2pNSF78byChhWGGu9C4CeDgJQ70mDCALXc
	O1+o03MPMd0UtVfLifxtd63SCl8nQzx8s/DX5dQgw4w3dU732mVky5HkKxheloU2n6Q==
X-Received: by 2002:a17:906:fcb3:: with SMTP id qw19mr105429441ejb.286.1561449192151;
        Tue, 25 Jun 2019 00:53:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgX5/BFj7/q+f5soUQhaV1o4Kn5Itp4tXRdDP2zyKL3J88+321e0LwcbAMGulCbARPbNjn
X-Received: by 2002:a17:906:fcb3:: with SMTP id qw19mr105429397ejb.286.1561449191317;
        Tue, 25 Jun 2019 00:53:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561449191; cv=none;
        d=google.com; s=arc-20160816;
        b=m08ASN4e+vpsgtjR0W97bhu6ylta5xFG62P/rSQCjunCryoIPwqwgmq+iDt9/QQGSy
         eFXdexN5YIQDt5+lLnxJIqD5bJeXp+wWrEkRU4Lk1yn3AApuvzNyI5EbL9g8/33qubyw
         TKYJSmCGxwuMcm+tygrmKbpYXoxF2conQGX5MjLbOXpcglsNZie3YybaIM+1gD515xQt
         4ZH5dtY1ctENreog2l80V/4fuiyPIxyA9ZLNHX+f4pUQpk/ugF2sNLN468jn4E4mWLdY
         21DUdmjAc2AdPsrL/pxANrDG2V31ok8eLCsZe30F6oTw74abNUb/3vUcsuW1ksQx+bKQ
         /K7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=pOYCJ3wCl+5Aq16br5xzf6IifgjC4BiDEDrEzJSV9Ig=;
        b=QhA72gNBuX3gJF1npnVc5XJAoFjGm3Tg8dxZTkOyHCVLfQqHTpyzAHTzS3azA9gXPQ
         xU8MqYneORnq4xvlAYYYVSKGVLAvx1f1pi/LfAgjulLceSOgtYnozUL1aScGNMyQBWOy
         YFOtcceYfESnl8ffTaS0mD4QrZaeSX7x10VqdMxKdqH4Lu8vIn2LXRIcirWD9Z5ZV2pG
         JHTeW6nHJ+xkUv2948+Lj4lN8z/o7u6iQN0Kp46jR2VjIdBFeZcF8tgUwpEueOPpLKZf
         IfXBMUQ62qQVFpuXl2//HpB0IFxuzVzTQfdgByhdakpsNYZbBCHRJD4RbiQmNTH0jrVH
         /m1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id o7si8086149ejd.303.2019.06.25.00.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:53:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 25 Jun 2019 09:53:10 +0200
Received: from suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Tue, 25 Jun 2019 08:52:35 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	dan.j.williams@intel.com,
	pasha.tatashin@soleen.com,
	Jonathan.Cameron@huawei.com,
	david@redhat.com,
	anshuman.khandual@arm.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 5/5] mm,memory_hotplug: Allow userspace to enable/disable vmemmap
Date: Tue, 25 Jun 2019 09:52:27 +0200
Message-Id: <20190625075227.15193-6-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190625075227.15193-1-osalvador@suse.de>
References: <20190625075227.15193-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It seems that we have some users out there that want to expose all
hotpluggable memory to userspace, so this implements a toggling mechanism
for those users who want to disable it.

By default, vmemmap pages mechanism is enabled.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/base/memory.c          | 33 +++++++++++++++++++++++++++++++++
 include/linux/memory_hotplug.h |  3 +++
 mm/memory_hotplug.c            |  6 +++++-
 3 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index e0ac9a3b66f8..6fca2c96cc08 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -573,6 +573,35 @@ static DEVICE_ATTR_WO(soft_offline_page);
 static DEVICE_ATTR_WO(hard_offline_page);
 #endif
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+static ssize_t vmemmap_hotplug_show(struct device *dev,
+				    struct device_attribute *attr, char *buf)
+{
+	if (vmemmap_enabled)
+		return sprintf(buf, "enabled\n");
+	else
+		return sprintf(buf, "disabled\n");
+}
+
+static ssize_t vmemmap_hotplug_store(struct device *dev,
+			   struct device_attribute *attr,
+			   const char *buf, size_t count)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (sysfs_streq(buf, "enable"))
+		vmemmap_enabled = true;
+	else if (sysfs_streq(buf, "disable"))
+		vmemmap_enabled = false;
+	else
+		return -EINVAL;
+
+	return count;
+}
+static DEVICE_ATTR_RW(vmemmap_hotplug);
+#endif
+
 /*
  * Note that phys_device is optional.  It is here to allow for
  * differentiation between which *physical* devices each
@@ -799,6 +828,10 @@ static struct attribute *memory_root_attrs[] = {
 	&dev_attr_hard_offline_page.attr,
 #endif
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+	&dev_attr_vmemmap_hotplug.attr,
+#endif
+
 	&dev_attr_block_size_bytes.attr,
 	&dev_attr_auto_online_blocks.attr,
 	NULL
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index e28e226c9a20..94b4adc1a0ba 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -131,6 +131,9 @@ extern int arch_add_memory(int nid, u64 start, u64 size,
 			struct mhp_restrictions *restrictions);
 extern u64 max_mem_size;
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+extern bool vmemmap_enabled;
+#endif
 extern bool memhp_auto_online;
 /* If movable_node boot option specified */
 extern bool movable_node_enabled;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b5106cb75795..32ee6fb7d3bf 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -70,6 +70,10 @@ void put_online_mems(void)
 
 bool movable_node_enabled = false;
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+bool vmemmap_enabled __read_mostly = true;
+#endif
+
 #ifndef CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
 bool memhp_auto_online;
 #else
@@ -1168,7 +1172,7 @@ int __ref add_memory_resource(int nid, struct resource *res, unsigned long flags
 		goto error;
 	new_node = ret;
 
-	if (mhp_check_correct_flags(flags))
+	if (vmemmap_enabled && mhp_check_correct_flags(flags))
 		restrictions.flags = flags;
 
 	/* call arch's memory hotadd */
-- 
2.12.3

