Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EEE66800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 13:29:00 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id b8so15757378qtj.21
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 10:29:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j188sor3688645qkc.57.2018.01.22.10.29.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 10:29:00 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 0/2] Documentation, powerpc, x86 : Memory Protection Keys
Date: Mon, 22 Jan 2018 10:28:34 -0800
Message-Id: <1516645716-10174-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, linux-doc@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, arnd@arndb.de

Memory protection keys enable applications to protect its
address space from inadvertent access from itself.

This feature is now enabled on powerpc architecture.
The patches moves the documentation to arch neutral directory and 
captures the latest information.

Ram Pai (2):
  Documentation/x86: Move protecton key documentation to arch neutral
    directory
  Documentation/vm: PowerPC specific updates to memory protection keys

 Documentation/vm/protection-keys.txt  |  132 +++++++++++++++++++++++++++++++++
 Documentation/x86/protection-keys.txt |   90 ----------------------
 2 files changed, 132 insertions(+), 90 deletions(-)
 create mode 100644 Documentation/vm/protection-keys.txt
 delete mode 100644 Documentation/x86/protection-keys.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
