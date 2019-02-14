Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95D7AC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:42:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C1BF222A4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:42:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C1BF222A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B04E28E0004; Thu, 14 Feb 2019 05:42:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A876A8E0002; Thu, 14 Feb 2019 05:42:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 955988E0005; Thu, 14 Feb 2019 05:42:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 289558E0002
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:42:46 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c53so2343012edc.9
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:42:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=LImqdQAWkxOsbk2Pd5WKzbDiKNLIDtx1r4tUAKQC8ac=;
        b=axx+K8qn2XqVj+pqihke4cJw72kgKih5ewebDH7s9VuuvR3isRcXw6EhOVuU90fyK/
         7EUMbj3/13SfvrkcjM0xQpPzlx4DJAWecZ7Mcib7Sgbb7IEwiGYSgTPeTh3rPlZpi/qS
         ZDFxNkh0aphcm2WOs841uTQyJUQpbilm0OUqQ/wdor4EEhnaSfN3QCOiyt2VLR5PToCw
         zrwlpHwuiCa6vjKiVQUerz9J451Byl0QM4xIU+I5eII+nmA39WtXQkGEbI+Eg3EziIDP
         gKkGTdodLLPILpwJRQLSBOOq6hBi81r6tv2syG4Jesbwlf8ShUe5DE/GOk9XLnxsxGyP
         rklQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: AHQUAuZTiT9GK5iS8ie0Ehxb8N/gT+3rLW2UXL0HtoH9Krny23DMb7ZB
	LQmNYZXwRBPJ3R4d2x2V7KHzTeOmi3Lsl2qbpxkBLLg5hBcmvCKvEJaZBSDlWNHtMUXvEXowU93
	X0Jl+VyZXAZirIN//EJIPeFnblz4H9clXjCJQxX5uWANeWCF1V8QOiHKdxfnuZ8S3UA==
X-Received: by 2002:a17:906:364d:: with SMTP id r13mr2227097ejb.183.1550140965620;
        Thu, 14 Feb 2019 02:42:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYTyi9ZZEd0D0fj9r2SBwBf3b4iPfbsjgamwXVscF2V29LmbkABc8a+21KvtuKYtEVk25nz
X-Received: by 2002:a17:906:364d:: with SMTP id r13mr2227044ejb.183.1550140964390;
        Thu, 14 Feb 2019 02:42:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550140964; cv=none;
        d=google.com; s=arc-20160816;
        b=IIlJPJVGTePpqBhgy4zMyVda4SvlIs2gwnOkr8WmR6+Mz1YjqOe20Hp+2fK+BWMts8
         KulJg2ERs0cdqfBJ6ukSD4btnhVi4A7OJf4I2XsIdQiO4i0zmFVORnI0bcwSSI58ZTRp
         pEvu6m3vfa6CTgMUaWKvNeVC7G1deQHeYSx+lWETozpLzksndfW4GE0q1ZUD/p93IJ9X
         KByl7jbrWAmJVMnZSL3QTSp2zEG81hO3fkUvyhsI4lu7MHEmNO7I79z/J2JiaA8RtLsQ
         eaxc63pcIwSu4yeJZB2kMLYMY/NcYl1f3lnHwuHi9HosgEQ+KPiuwcxEzs85YVgmVMv6
         90AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=LImqdQAWkxOsbk2Pd5WKzbDiKNLIDtx1r4tUAKQC8ac=;
        b=Q/Yatj1O9EZ1F+JIH/YoRThiXCWWZZgWCdX+jLhUBoGxfy1UxVu8FSANkXJXyoDGCC
         WRjimE/IudqBz1eCFBMjLHsaCU7tUKJ2WcZxxLw4H4AEYDeYwEm1LbR8uQnx9nq3L2H8
         Jc3jb8yytRAdGmIU9V882rZGSuujZhtS9uTEO0+3wVtsdmnzegN9pT0KQdgIS8npvsEr
         vAXDBicd1PxosJEsP5rmksjLnLT6GozHzUaCLa+cg8iCkHaukgmY5G8nxb3ydWf3o671
         7s9e2BJqENvG/ovYDCNrwpC0IARf7Z1UKxHXium6S9xJ/JCnq21g0TTFmbfs+kcVpzsU
         MO9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d20si539417ejb.28.2019.02.14.02.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:42:44 -0800 (PST)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D5949AFD4;
	Thu, 14 Feb 2019 10:42:43 +0000 (UTC)
From: Juergen Gross <jgross@suse.com>
To: linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	x86@kernel.org,
	linux-mm@kvack.org
Cc: boris.ostrovsky@oracle.com,
	sstabellini@kernel.org,
	hpa@zytor.com,
	tglx@linutronix.de,
	mingo@redhat.com,
	bp@alien8.de,
	Juergen Gross <jgross@suse.com>
Subject: [PATCH v3 0/2] x86: respect memory size limits
Date: Thu, 14 Feb 2019 11:42:38 +0100
Message-Id: <20190214104240.24428-1-jgross@suse.com>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On a customer system running Xen a boot problem was observed due to
the kernel not respecting the memory size limit imposed by the Xen
hypervisor.

During analysis I found the same problem should be able to occur on
bare metal in case the memory would be limited via the "mem=" boot
parameter.

The system this problem has been observed on has tons of memory
added via PCI. So while in the E820 map the not to be used memory has
been wiped out the additional PCI memory is detected during ACPI scan
and it is added via __add_memory().

This small series tries to repair the issue by testing the imposed
memory limit during the memory hotplug process and refusing to add it
in case the limit is being violated.

I've chosen to refuse adding the complete memory chunk in case the
limit is reached instead of adding only some of the memory, as I
thought this would result in less problems (e.g. avoiding to add
only parts of a 128MB memory bar which might be difficult to remove
later).

Changes in V3:
- patch 2: remember possible max_mem_size value from kernel parameters
- patch 2: set allowed size to end of local E820 map's RAM

Changes in V2:
- patch 1: set initial allowed size to U64_MAX instead -1
- patch 2: set initial allowed size to end of E820 RAM

Juergen Gross (2):
  x86: respect memory size limiting via mem= parameter
  x86/xen: dont add memory above max allowed allocation

 arch/x86/kernel/e820.c         |  5 +++++
 arch/x86/xen/setup.c           | 13 +++++++++++++
 drivers/xen/xen-balloon.c      | 11 +++++++++++
 include/linux/memory_hotplug.h |  2 ++
 include/xen/xen.h              |  4 ++++
 mm/memory_hotplug.c            |  6 ++++++
 6 files changed, 41 insertions(+)

-- 
2.16.4

