Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 485006B000E
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 08:58:03 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t14so317965wmc.5
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:58:03 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 6si4341195edf.460.2018.01.30.05.58.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 05:58:02 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [LSF/MM TOPIC] Protectable Dynamically allocated Memory for both
 kernel and userspace
Message-ID: <c6c462fe-4aa1-3922-725d-03c3b1da0786@huawei.com>
Date: Tue, 30 Jan 2018 15:57:58 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>
Cc: Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@google.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, linux-security-module <linux-security-module@vger.kernel.org>

Hi,

At the LSF/MM summit, I would like to discuss the following topics:

- Dynamic allocation of protectable (read/only) memory in kernel space
- Rare Write option for the aforementioned dynamic allocation
  (this is most likely related to Kees Cook's rare-write proposal)
- Support for userspace to mprotect selected pages:
   * as permanently R/O
   * as rare write
    (this might be easier to implement than kernel rare-write)
   Probably both of these will also require a separate userspace memory
   allocator, which understands pools, or at the very least, can support
   different types of pages.
- Optimization of vmalloc (combining vmap_area and vm_struct structures)

--
igor stoppa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
