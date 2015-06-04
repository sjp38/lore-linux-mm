Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 60EDB900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 12:57:10 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so34637117pdb.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 09:57:10 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id re12si6732022pdb.36.2015.06.04.09.57.09
        for <linux-mm@kvack.org>;
        Thu, 04 Jun 2015 09:57:09 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC PATCH 02/12] mm: introduce mirror_info
Date: Thu, 4 Jun 2015 16:57:07 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A8D57F@ORSMSX114.amr.corp.intel.com>
References: <55704A7E.5030507@huawei.com> <55704B55.1020403@huawei.com>
In-Reply-To: <55704B55.1020403@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

+#ifdef CONFIG_MEMORY_MIRROR
+struct numa_mirror_info {
+	int node;
+	unsigned long start;
+	unsigned long size;
+};
+
+struct mirror_info {
+	int count;
+	struct numa_mirror_info info[MAX_NUMNODES];
+};

Do we really need this?  My patch series leaves all the mirrored memory in
the memblock allocator tagged with the MEMBLOCK_MIRROR flag.  Can't
we use that information when freeing the boot memory into the runtime
free lists?

If we can't ... then [MAX_NUMNODES] may not be enough.  We may have
more than one mirrored range on each node. Current h/w allows two ranges
per node.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
