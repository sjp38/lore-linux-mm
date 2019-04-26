Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE2F3C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 01:38:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A509206BF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 01:38:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A509206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABED96B0005; Thu, 25 Apr 2019 21:38:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6D9C6B0006; Thu, 25 Apr 2019 21:38:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95CBF6B0007; Thu, 25 Apr 2019 21:38:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC256B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:38:19 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id w53so1517508qtj.22
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 18:38:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=7W6Qk+TWealOeFDjILGAXqwEa4Zhorp75rw4BuTGpZk=;
        b=BF8GFmxqvEvRdaOHScBy8fN23lu+aHtIVtT2NSMbRcb6R4HL8sc6tX2Y93abDAGEuX
         IhRhbLyt2OQ2IMt46nfN20VxRQYhGeg/RLAB/3d7m2WB7siQZa16B6vVn76Z7geyuj0n
         7MwvCOXJf4gGje4ZA7GpMYZjqlArF8aYxlMZSbHOQAudusQ3zO/srg4lCq2T5Oz1KQf1
         BoTUXLLvtB26Y3wxW5Y4Et4ebOIRLQv0n/isXCVB+QY7O8mQ/l6G6j8UhRuqJhAOtwc+
         qJNS/SKIPXt+PcVE6UamskPihLFk2zqnQfVYP0tqPimMkHDYueGMTF/Yg3C4ebisGZY1
         VXRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAViCNDWklxpYUhC5QqR5YKAnWyOQAj1ayjGvH3hn6z8i/Q4Jl1y
	RNVxqFLVFjGN5mutRXjmjC8Gdi1C6w5RwyYOfxFmwmD/a9mcClfvWd2uJT/hu93322tzYUo3tqE
	0MbB4ZBwHFBATYC17pYwQPVt353ATqI1HeIOQ68NlXQ6xgjIEGKFHnbH6u0HJJCrE9Q==
X-Received: by 2002:ac8:810:: with SMTP id u16mr31976734qth.254.1556242699113;
        Thu, 25 Apr 2019 18:38:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrx8yZle0a+F3K3lk2YNrRSbmsDxHoae/k171nl92tK8G0SHxocQaJ2Woi7zRcr5PdEyfU
X-Received: by 2002:ac8:810:: with SMTP id u16mr31976680qth.254.1556242698170;
        Thu, 25 Apr 2019 18:38:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556242698; cv=none;
        d=google.com; s=arc-20160816;
        b=hBXKxZ/8GQw+ZmXnf3A5qrbprqAR1VBH+L2Ra5GUiCgD7fcTp0RjD5a1F+jC9kID15
         uJJCR9QDFuc8ld45L0MnUakhK7FzQT5aLTWiSRUfZ8HFELH2JJyQi3B6XIk8ZmUEGkK1
         Otxoyn4sd83fj/MjYTO9gdg/XiHPt3bDHaWs0VihKFnYW7fiZWSGq+9Bh/VTqYVYioZB
         8tyuwHbA8tBP6l19pV7xTT1z8pOKsssLRABMvbUIe0GXUCHzHuA8p1QnA7ZZwwKWvu0d
         +48gDig191V5xjEbsnktRV30+yTQ/jykDKu/E3qK16crAb4XsIIverE32mzdjw6Z6Hq7
         Fvng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date;
        bh=7W6Qk+TWealOeFDjILGAXqwEa4Zhorp75rw4BuTGpZk=;
        b=l0ac1egbG2vT0ccUEy4cMA2NW4pSNIaAVgWAS/ZruI5fYcXEwPO3tPW7LA4w0TWRjR
         coD0aODHFN3hfoO3kDiKYXxV9W2dKgDWGT4J624mDYXUoOrjYR1XeTZZD27TjODOvM8+
         WPN0XAAB8fDf6xkFBZaE/EbYDUaZj6Z4QiK2KQqB9kZnOw8xtzdb2gz6E4jeQtiVAI5u
         SwY7dsyZV43qEm29ZSrewCVaEP05lxxIBxRL9CCpAs3jfkhNfAqn/LgxEA8N2ZskQ2TY
         VDALyjs7Qjy2Vvd4ErnEgh9oXKLK77sCTUTEMOTQbd6Ea1oYiquA4d13pGaSuc9AK5MD
         ogbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o70si5550908qka.91.2019.04.25.18.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 18:38:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 447E63005FE7;
	Fri, 26 Apr 2019 01:38:17 +0000 (UTC)
Received: from redhat.com (ovpn-120-47.rdu2.redhat.com [10.10.120.47])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5865F1820F;
	Fri, 26 Apr 2019 01:38:16 +0000 (UTC)
Date: Thu, 25 Apr 2019 21:38:14 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [LSF/MM TOPIC] Direct block mapping through fs for device
Message-ID: <20190426013814.GB3350@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 26 Apr 2019 01:38:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I see that they are still empty spot in LSF/MM schedule so i would like to
have a discussion on allowing direct block mapping of file for devices (nic,
gpu, fpga, ...). This is mm, fs and block discussion, thought the mm side
is pretty light ie only adding 2 callback to vm_operations_struct:

    int (*device_map)(struct vm_area_struct *vma,
                      struct device *importer,
                      struct dma_buf **bufp,
                      unsigned long start,
                      unsigned long end,
                      unsigned flags,
                      dma_addr_t *pa);

    // Some flags i can think of:
    DEVICE_MAP_FLAG_PIN // ie return a dma_buf object
    DEVICE_MAP_FLAG_WRITE // importer want to be able to write
    DEVICE_MAP_FLAG_SUPPORT_ATOMIC_OP // importer want to do atomic operation
                                      // on the mapping

    void (*device_unmap)(struct vm_area_struct *vma,
                         struct device *importer,
                         unsigned long start,
                         unsigned long end,
                         dma_addr_t *pa);

Each filesystem could add this callback and decide wether or not to allow
the importer to directly map block. Filesystem can use what ever logic they
want to make that decision. For instance if they are page in the page cache
for the range then it can say no and the device would fallback to main
memory. Filesystem can also update its internal data structure to keep
track of direct block mapping.

If filesystem decide to allow the direct block mapping then it forward the
request to the block device which itself can decide to forbid the direct
mapping again for any reasons. For instance running out of BAR space or
peer to peer between block device and importer device is not supported or
block device does not want to allow writeable peer mapping ...


So event flow is:
    1  program mmap a file (end never intend to access it with CPU)
    2  program try to access the mmap from a device A
    3  device A driver see device_map callback on the vma and call it
    4a on success device A driver program the device to mapped dma address
    4b on failure device A driver fallback to faulting so that it can use
       page from page cache

This API assume that the importer does support mmu notifier and thus that
the fs can invalidate device mapping at _any_ time by sending mmu notifier
to all mapping of the file (for a given range in the file or for the whole
file). Obviously you want to minimize disruption and thus only invalidate
when necessary.

The dma_buf parameter can be use to add pinning support for filesystem who
wish to support that case too. Here the mapping lifetime get disconnected
from the vma and is transfer to the dma_buf allocated by filesystem. Again
filesystem can decide to say no as pinning blocks has drastic consequence
for filesystem and block device.


This has some similarities to the hmmap and caching topic (which is mapping
block directly to CPU AFAIU) but device mapping can cut some corner for
instance some device can forgo atomic operation on such mapping and thus
can work over PCIE while CPU can not do atomic to PCIE BAR.

Also this API here can be use to allow peer to peer access between devices
when the vma is a mmap of a device file and thus vm_operations_struct come
from some exporter device driver. So same 2 vm_operations_struct call back
can be use in more cases than what i just described here.


So i would like to gather people feedback on general approach and few things
like:
    - Do block device need to be able to invalidate such mapping too ?

      It is easy for fs the to invalidate as it can walk file mappings
      but block device do not know about file.

    - Do we want to provide some generic implementation to share accross
      fs ?

    - Maybe some share helpers for block devices that could track file
      corresponding to peer mapping ?


Cheers,
Jérôme

