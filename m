Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC91DC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:46:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A147921901
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:46:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A147921901
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 418CC6B0006; Thu, 21 Mar 2019 09:46:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F0776B0007; Thu, 21 Mar 2019 09:46:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 307546B0008; Thu, 21 Mar 2019 09:46:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 11B5F6B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 09:46:10 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q21so5922188qtf.10
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:46:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=i2Fq96/kzkzLHPA8FJ3ko9s5NVfH5SpQnfA7trhmckE=;
        b=C68NYCApNaD60vrvNgklCX34ye13YhkAtNKayZc6rwl9CodVpNESYAtH5+uFnFr5nn
         bQivsgN/zgM7BpmN52nHi2Qj9t7F7LEgUD9njFicgf+FHms5Wu6Ez1CK20soGtyW4CO4
         5hu5v4WsdY7tzzikZbY3LKM3AMDfZhWrP0npn8xct/C5dka93gg57sOtpbjd604dMgDK
         aaew24/+zdFO41ClDSZ627VG+8cuE05EH0R7Ea1JiJr92MsKpx6rfGpNhUhWqZGMMzT5
         pd2XejVtR4wJixGoH09feQ8usBHy9PDAEufC4eFGKUQLXKrw8A14WiGkwrsVXu+IPieU
         Oh5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVSh2TrUQm45iB2YpfTBmPm2JARK6HcoYL+yH1f/PVgqazTWGfk
	gXLVas7ee8baWSusGIWiTHfPgJ2AiBv/X2KA/A3dChQ9EcEE0+fpZ48qPDofGj+Cd2UbPfqKDio
	7VfWrwk4aTbMO+nsHEIAViVTdfwmIjJiGr8ELy012oQ5XOSbtBpdolbDiCudQ7hKrOA==
X-Received: by 2002:ac8:110d:: with SMTP id c13mr3078470qtj.234.1553175969763;
        Thu, 21 Mar 2019 06:46:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9QGKBDlKxftAJslrGjn8501VwCWYYehjh2tUWWkK9PKSb5YO+kXQaFgM0Rj8G8JRB/fa6
X-Received: by 2002:ac8:110d:: with SMTP id c13mr3078400qtj.234.1553175968941;
        Thu, 21 Mar 2019 06:46:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553175968; cv=none;
        d=google.com; s=arc-20160816;
        b=qNhltsQ0YGLqC61gRHfIucOnX3nBdHGazaYzNcSlQnKuk90SYheyRCAT1neIqI2lt+
         QJzi8HzMin5W0gCB8fm66oM0QDTju8CsqZrfcZ6/+md1UZLH/v3Z3VUiqdfhijHSCgyg
         MgFrZgNDEhHxZjlHLmsJfBVTVA1Lkznhfg0qEcMdQKM5D6tLd0aIVGQvYzDx4HadET0B
         QQyNa7UicecVDSPGwBms3VaXtidR5wAn4qbLZp1yK3kIkbDphRFXqago5vB48S338Wwl
         5tELxRC5zanuFPBrJ+Y9ZQBFk27dYsvMmknCyWN11dGpoKEFeE2vw5wEUZjbH86GEGVa
         dWWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=i2Fq96/kzkzLHPA8FJ3ko9s5NVfH5SpQnfA7trhmckE=;
        b=Y5sD3ecRkiFHI35FQxtRR6OsEKKAqp1fT8yxnHWFPqvy534sv16EOlmgnWBpdL54ZU
         kN/yFrt6nCFdo+IiVLDZoEMS5PuaUy5aoPWHiOZJXQzLfprBumz3bkmiHvYn9isyJsS2
         9+kjmNlt+OQjag70HorNTHsRKMAFUAYNXiD49YKo0nVB2OzsRPumJH6jWkuX0HnSkEoK
         +e4apgn62cbgoAz/LfOp6Gi1ZNP+qRonQlwem7Am0/utzFeYop7FwXJD+G4KBJdO69Zk
         iSjctdu7M9HehY7PbVQYDCk9/z0rLSOQuI5RS4uHUv95t6B+Yc62BxQzOY+2PtSpkAep
         pPIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v11si3029034qkl.268.2019.03.21.06.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 06:46:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B454E1E308;
	Thu, 21 Mar 2019 13:46:07 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1087C600C0;
	Thu, 21 Mar 2019 13:46:05 +0000 (UTC)
Date: Thu, 21 Mar 2019 09:46:04 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH RESEND 0/3] mm modifications / helpers for emulated
 GPU coherent memory
Message-ID: <20190321134603.GB2904@redhat.com>
References: <20190321132140.114878-1-thellstrom@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190321132140.114878-1-thellstrom@vmware.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 21 Mar 2019 13:46:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 01:22:22PM +0000, Thomas Hellstrom wrote:
> Resending since last series was sent through a mis-configured SMTP server.
> 
> Hi,
> This is an early RFC to make sure I don't go too far in the wrong direction.
> 
> Non-coherent GPUs that can't directly see contents in CPU-visible memory,
> like VMWare's SVGA device, run into trouble when trying to implement
> coherent memory requirements of modern graphics APIs. Examples are
> Vulkan and OpenGL 4.4's ARB_buffer_storage.
> 
> To remedy, we need to emulate coherent memory. Typically when it's detected
> that a buffer object is about to be accessed by the GPU, we need to
> gather the ranges that have been dirtied by the CPU since the last operation,
> apply an operation to make the content visible to the GPU and clear the
> the dirty tracking.
> 
> Depending on the size of the buffer object and the access pattern there are
> two major possibilities:
> 
> 1) Use page_mkwrite() and pfn_mkwrite(). (GPU buffer objects are backed
> either by PCI device memory or by driver-alloced pages).
> The dirty-tracking needs to be reset by write-protecting the affected ptes
> and flush tlb. This has a complexity of O(num_dirty_pages), but the
> write page-fault is of course costly.
> 
> 2) Use hardware dirty-flags in the ptes. The dirty-tracking needs to be reset
> by clearing the dirty bits and flush tlb. This has a complexity of
> O(num_buffer_object_pages) and dirty bits need to be scanned in full before
> each gpu-access.
> 
> So in practice the two methods need to be interleaved for best performance.
> 
> So to facilitate this, I propose two new helpers, apply_as_wrprotect() and
> apply_as_clean() ("as" stands for address-space) both inspired by
> unmap_mapping_range(). Users of these helpers are in the making, but needs
> some cleaning-up.

To be clear this should _only be use_ for mmap of device file ? If so
the API should try to enforce that as much as possible for instance by
mandating the file as argument so that the function can check it is
only use in that case. Also big scary comment to make sure no one just
start using those outside this very limited frame.

> 
> There's also a change to x_mkwrite() to allow dropping the mmap_sem while
> waiting.

This will most likely conflict with userfaultfd write protection. Maybe
building your thing on top of that would be better.

https://lwn.net/Articles/783571/

I will take a cursory look at the patches.

Cheers,
Jérôme

