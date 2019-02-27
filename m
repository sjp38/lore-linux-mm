Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC745C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 965E82133D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 965E82133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFF758E0009; Wed, 27 Feb 2019 17:50:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB1538E0004; Wed, 27 Feb 2019 17:50:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B17308E000A; Wed, 27 Feb 2019 17:50:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68F058E0009
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 17:50:34 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e2so13495544pln.12
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 14:50:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hz9w91aIPkE0E9ap/WrfhsBJuY4OqRXIHLZmUsGEF7E=;
        b=PcN9qE5vEepQ9v+trqH18OnJqrFJscwMRcXZz05gee7eiydh4jCF9fXCtqa5WD8Xfq
         Npev6HY7WCAXo37C2qQiaZwre0VL1APwNB9ODrb85twX3tZbMKOeVNEXpwhMU6+avEXl
         CNK4F0mOD2Nm+elVYlXLXpTnTdBfK/k5z92HNfYppXIkM7uGpLJoFWjxnTxWXbm8caRl
         XVlvsdga1m6m/orRsJ7RxKVo+0Iqca2QGsM+xVJ8ODw5xaHmKT+NxUjjLPCWI6RNRkvg
         aKz9eeGMHCntp7t/WRtJn8+4Hl8N7AtQe3rmEbphVwGk5YgnS80Atl8NNzWEPIxS7H35
         uNxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaevupagATBmGpuBRKhaNAq33NoP10FGS30yzVEGk8+MFiqJQLz
	FjXjKvPXakLyaR3CWDvv5wYsijOX0gitviClBh7s641yNRvwbOUQD4Exk1XXfEXPIX7RuCk+oax
	KdTvTEDWoVWner4oXClyOUpx2ybK4PJ5pKL2awzjGD2R1pKKBQQHnk+8xR5t+CefD0w==
X-Received: by 2002:a17:902:2f03:: with SMTP id s3mr4527383plb.277.1551307834085;
        Wed, 27 Feb 2019 14:50:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbCM16F/rQ6lUaObpr/c0Bffjynq6sg+tmIEGTvcyDTzfPjLfwy5JwsfgVei3FZM8PCElLN
X-Received: by 2002:a17:902:2f03:: with SMTP id s3mr4527292plb.277.1551307832877;
        Wed, 27 Feb 2019 14:50:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551307832; cv=none;
        d=google.com; s=arc-20160816;
        b=izm8/+qBlX9Q5uvM3mpZlTwg1NG+Wi7EKb9QOyWYQmDAocBVGV1bHDn3CZVuvwttkd
         yOqHA9dkFGTYIrMcfrHIRAsdJZF2fUacbMMybYpFI0s/fgvAKBFU2FaC2sM/rudbrTlb
         KHxDYb7ZDW0GNDIrS541ct17aNDzdSlsycvXLH6j3jU3HrvqCbVb8gVyFiq9JUrwQeCt
         WhIseE6JOQMLP1allo0Z418sTsctlSab9aAXD0gZfuevI7UdsULQM3huF8e80qjYpmgy
         WexxfbLJTeBvoKKB5dbH7w0Cox8GqH22CFBYKWc/AtFYAUjUMnfN1Rmi2DcyotLo5aSE
         Yd5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hz9w91aIPkE0E9ap/WrfhsBJuY4OqRXIHLZmUsGEF7E=;
        b=k+X1OFIhw078wO0jfCwYvLNGdGF3dbtGDN3EET7trBdlc7h76dWJcX3SK1MdAig0KD
         0LhvDvSX8Dslo0bN4Byojrmdwm/w1wS6iqagbVZpq4PEaKDr+UQFc9K6ZR9v/Q+AW9O2
         MHB8P8iJqK1L2qmYR7JJkZPuV8v4E8zmNG7ofR4MEEgWBRAnYDc1/+smVl601Od+wUbc
         ZPCMxZPCPbTFBdXM7Q+QXhwZFMNJ294hTdH7l5rPE7xjgxqpB89CgKjNXJte86ZcfynU
         FAOj+gDzUpJRwsTutkIYELXi56P9xZsqx0k/8alr3a9mxU+djopL00U51JgMbJkm4yMk
         IGfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z20si10836901pgf.324.2019.02.27.14.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 14:50:32 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Feb 2019 14:50:32 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,420,1544515200"; 
   d="scan'208";a="121349410"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga008.jf.intel.com with ESMTP; 27 Feb 2019 14:50:31 -0800
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv7 05/10] node: Add heterogenous memory access attributes
Date: Wed, 27 Feb 2019 15:50:33 -0700
Message-Id: <20190227225038.20438-6-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190227225038.20438-1-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Heterogeneous memory systems provide memory nodes with different latency
and bandwidth performance attributes. Provide a new kernel interface
for subsystems to register the attributes under the memory target
node's initiator access class. If the system provides this information,
applications may query these attributes when deciding which node to
request memory.

The following example shows the new sysfs hierarchy for a node exporting
performance attributes:

  # tree -P "read*|write*"/sys/devices/system/node/nodeY/accessZ/initiators/
  /sys/devices/system/node/nodeY/accessZ/initiators/
  |-- read_bandwidth
  |-- read_latency
  |-- write_bandwidth
  `-- write_latency

The bandwidth is exported as MB/s and latency is reported in
nanoseconds. The values are taken from the platform as reported by the
manufacturer.

Memory accesses from an initiator node that is not one of the memory's
access "Z" initiator nodes linked in the same directory may observe
different performance than reported here. When a subsystem makes use
of this interface, initiators of a different access number may not have
the same performance relative to initiators in other access numbers, or
omitted from the any access class' initiators.

Descriptions for memory access initiator performance access attributes
are added to sysfs stable documentation.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 28 ++++++++++++++
 drivers/base/Kconfig                        |  8 ++++
 drivers/base/node.c                         | 59 +++++++++++++++++++++++++++++
 include/linux/node.h                        | 26 +++++++++++++
 4 files changed, 121 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index fb843222a281..41cb9345e1e0 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -114,3 +114,31 @@ Contact:	Keith Busch <keith.busch@intel.com>
 Description:
 		The directory containing symlinks to memory targets that
 		this initiator node has class "Y" access.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/read_bandwidth
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's read bandwidth in MB/s when accessed from
+		nodes found in this access class's linked initiators.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/read_latency
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's read latency in nanoseconds when accessed
+		from nodes found in this access class's linked initiators.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/write_bandwidth
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's write bandwidth in MB/s when accessed from
+		found in this access class's linked initiators.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/write_latency
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's write latency in nanoseconds when access
+		from nodes found in this class's linked initiators.
diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 059700ea3521..a7438a58c250 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -149,6 +149,14 @@ config DEBUG_TEST_DRIVER_REMOVE
 	  unusable. You should say N here unless you are explicitly looking to
 	  test this functionality.
 
+config HMEM_REPORTING
+	bool
+	default n
+	depends on NUMA
+	help
+	  Enable reporting for heterogenous memory access attributes under
+	  their non-uniform memory nodes.
+
 source "drivers/base/test/Kconfig"
 
 config SYS_HYPERVISOR
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 6f4097680580..2de546a040a5 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -71,6 +71,9 @@ struct node_access_nodes {
 	struct device		dev;
 	struct list_head	list_node;
 	unsigned		access;
+#ifdef CONFIG_HMEM_REPORTING
+	struct node_hmem_attrs	hmem_attrs;
+#endif
 };
 #define to_access_nodes(dev) container_of(dev, struct node_access_nodes, dev)
 
@@ -148,6 +151,62 @@ static struct node_access_nodes *node_init_node_access(struct node *node,
 	return NULL;
 }
 
+#ifdef CONFIG_HMEM_REPORTING
+#define ACCESS_ATTR(name) 						   \
+static ssize_t name##_show(struct device *dev,				   \
+			   struct device_attribute *attr,		   \
+			   char *buf)					   \
+{									   \
+	return sprintf(buf, "%u\n", to_access_nodes(dev)->hmem_attrs.name); \
+}									   \
+static DEVICE_ATTR_RO(name);
+
+ACCESS_ATTR(read_bandwidth)
+ACCESS_ATTR(read_latency)
+ACCESS_ATTR(write_bandwidth)
+ACCESS_ATTR(write_latency)
+
+static struct attribute *access_attrs[] = {
+	&dev_attr_read_bandwidth.attr,
+	&dev_attr_read_latency.attr,
+	&dev_attr_write_bandwidth.attr,
+	&dev_attr_write_latency.attr,
+	NULL,
+};
+
+/**
+ * node_set_perf_attrs - Set the performance values for given access class
+ * @nid: Node identifier to be set
+ * @hmem_attrs: Heterogeneous memory performance attributes
+ * @access: The access class the for the given attributes
+ */
+void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
+			 unsigned access)
+{
+	struct node_access_nodes *c;
+	struct node *node;
+	int i;
+
+	if (WARN_ON_ONCE(!node_online(nid)))
+		return;
+
+	node = node_devices[nid];
+	c = node_init_node_access(node, access);
+	if (!c)
+		return;
+
+	c->hmem_attrs = *hmem_attrs;
+	for (i = 0; access_attrs[i] != NULL; i++) {
+		if (sysfs_add_file_to_group(&c->dev.kobj, access_attrs[i],
+					    "initiators")) {
+			pr_info("failed to add performance attribute to node %d\n",
+				nid);
+			break;
+		}
+	}
+}
+#endif
+
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 static ssize_t node_read_meminfo(struct device *dev,
 			struct device_attribute *attr, char *buf)
diff --git a/include/linux/node.h b/include/linux/node.h
index f34688a203c1..45e14e1e0c18 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -20,6 +20,32 @@
 #include <linux/list.h>
 #include <linux/workqueue.h>
 
+/**
+ * struct node_hmem_attrs - heterogeneous memory performance attributes
+ *
+ * @read_bandwidth:	Read bandwidth in MB/s
+ * @write_bandwidth:	Write bandwidth in MB/s
+ * @read_latency:	Read latency in nanoseconds
+ * @write_latency:	Write latency in nanoseconds
+ */
+struct node_hmem_attrs {
+	unsigned int read_bandwidth;
+	unsigned int write_bandwidth;
+	unsigned int read_latency;
+	unsigned int write_latency;
+};
+
+#ifdef CONFIG_HMEM_REPORTING
+void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
+			 unsigned access);
+#else
+static inline void node_set_perf_attrs(unsigned int nid,
+				       struct node_hmem_attrs *hmem_attrs,
+				       unsigned access)
+{
+}
+#endif
+
 struct node {
 	struct device	dev;
 	struct list_head access_list;
-- 
2.14.4

