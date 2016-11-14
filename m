Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 519C96B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 18:59:38 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id ro13so101167749pac.7
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:59:38 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id k72si24136675pge.102.2016.11.14.15.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 15:59:37 -0800 (PST)
Date: Tue, 15 Nov 2016 07:58:51 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 5439/5763] fs/namespace.c:1185:9-10: WARNING:
 return of 0/1 in function 'path_is_mountpoint' with return type bool
Message-ID: <201611150731.dUsDxUoh%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Kent <ikent@redhat.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   b60de3eba5c3cf3a230c121def7c57aafa72c4f8
commit: 5910290273fdaf6dc1f6e8d4afdee5c5608b2b69 [5439/5763] vfs: add path_is_mountpoint() helper


coccinelle warnings: (new ones prefixed by >>)

>> fs/namespace.c:1185:9-10: WARNING: return of 0/1 in function 'path_is_mountpoint' with return type bool
>> fs/namespace.c:1199:9-10: WARNING: return of 0/1 in function 'path_is_mountpoint_rcu' with return type bool

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
