Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C45DC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 22:09:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E37E220820
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 22:09:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E37E220820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E6546B0006; Tue,  9 Apr 2019 18:09:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 796616B000A; Tue,  9 Apr 2019 18:09:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 685C66B0010; Tue,  9 Apr 2019 18:09:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3142B6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 18:09:00 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m35so278434pgl.6
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 15:09:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fGG/tSwEukFMtFeaUo7HernsfMFN3A0V5oWQmOEzuBE=;
        b=YShkOIAhli1vb2DGzE56EevufKaKWDTnvonLm9RxAT0EiVagFU4VrAgfkRoBNnBAAU
         ql3WNMMCY7JPQqtDMVfTBW1H2/nqJPyGilXyo+mHEpvgCCAuLl5aVQnrfjMSgzT+kTmx
         IapGpGTOSW9OAZxV1XUNXqo3F+ECJ/pE6UuRio4b7M7XI2XmtAw7s4YYu3bns1VjIgw/
         Lv3ZjCzNQ6LsO0Sk6C2w3f7yVBO/lsHL50xfOee5eOlq9U2mqavxjPbIIBkIkaRigjfb
         VlAuTYNGKY4eOxPuXp5jx0lALTkQBp8YDQwgJsoTtkmFH0PHVrUwrFGDh5PABOz6Zgs3
         5iIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAX3E2anIc86ztiq773UADRWP1qBuveCK3NiEvZWWFaa4ExYt+bZ
	dqDAh/g1OBW7plCqPQQ2yyIqJVQZ00njm9/P4TdJTfX//73tuEOBUM+EaZO9DVT37Qp+F6LQ+0v
	nD31UprDBCnpLSDCsn/w9Qbi0nNAtgaBXCUyyUVfJcmuDfl+m7NkxthMHbTcDVqYvNA==
X-Received: by 2002:a63:195e:: with SMTP id 30mr36936166pgz.312.1554847739685;
        Tue, 09 Apr 2019 15:08:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3yZ7SpOMG1kH/OTk11w1jHEo+tpNNlxOZgVUVM104UeJ5hjrEVJSAMMEe6qID4Uw5D3hU
X-Received: by 2002:a63:195e:: with SMTP id 30mr36936063pgz.312.1554847738565;
        Tue, 09 Apr 2019 15:08:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554847738; cv=none;
        d=google.com; s=arc-20160816;
        b=XHdIFVjMRzI3zdhlAKa7V1ZZg8dCh+/IRQgzggjld0epvdq16UAnCnPlPp81Vc38Rk
         wrLFsg9OsBKho0ba17qzyGUfPrsXQ6tCn3uROLZWGztAjiEUqcSOAPqHPHfQ7ri6COZD
         UEeZLERwBvkNAoE9pf7F5P9qwQyuJu/dArCXJV/Aq22k/1o7g1LoRAOkBTwByAgoJby2
         7eNANdARn4CLXa5UQATQqH+scVYqwRHQi5Wf17vK82Ggj/TILYRFR+LHSaZJgXuiO4Wl
         egTVWPWQ+3OEaFuOd23WjIcxSs/z7dNk8jhn+YyuN5y8zM8GQmoNolgBKAkI2ayZbCa6
         8J+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=fGG/tSwEukFMtFeaUo7HernsfMFN3A0V5oWQmOEzuBE=;
        b=N6ECXagoMiGZh8ApuNrMLEtz0FFH2kzA0kIKah4+xKO37dmUJ9ubrvID0OfqnRRh9N
         2h1Bn2EhCgRRPHmLG5nTnfl0REAGGbO+1l6ZnOH84jxI1tjG5Lu0AbI62DxLwQdFZK4X
         aEG2yK+YV8vt9HylT6t1TGyEefjMR9i7Mtf1qnxU+XiaI0bua0iYzWhKGeWhcdo2kQue
         EEr+BNIbUOarKYaAMMJPQvan6eHcN2Z2Ka66n/XSwFy9LVq0IaiNJuZZOHAvuzuiIDGo
         AV+zQAL/vjWMEl0y6GYFbVp3mjCSNd7cbt3cyBSomTyJzmN1Kp8hphliFVtLKr5eeEA9
         q7aA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 102si31568206plf.250.2019.04.09.15.08.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 15:08:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 0C27A1059;
	Tue,  9 Apr 2019 22:08:57 +0000 (UTC)
Date: Tue, 9 Apr 2019 15:08:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: jglisse@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christian
 =?ISO-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Jani Nikula
 <jani.nikula@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan
 Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu
 <peterx@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Jason
 Gunthorpe <jgg@mellanox.com>, Ross Zwisler <zwisler@kernel.org>, Dan
 Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>,
 Alex Deucher <alexander.deucher@amd.com>, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1?=
 =?UTF-8?Q?=C5=99?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>,
 Ben Skeggs <bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
 John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, Arnd Bergmann
 <arnd@arndb.de>
Subject: Re: [PATCH v6 0/8] mmu notifier provide context informations
Message-Id: <20190409150855.a6cfee7e7c5698a9cd8ecb7c@linux-foundation.org>
In-Reply-To: <20190326164747.24405-1-jglisse@redhat.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Mar 2019 12:47:39 -0400 jglisse@redhat.com wrote:

> From: J=E9r=F4me Glisse <jglisse@redhat.com>
>=20
> (Andrew this apply on top of my HMM patchset as otherwise you will have
>  conflict with changes to mm/hmm.c)
>=20
> Changes since v5:
>     - drop KVM bits waiting for KVM people to express interest if they
>       do not then i will post patchset to remove change_pte_notify as
>       without the changes in v5 change_pte_notify is just useless (it
>       it is useless today upstream it is just wasting cpu cycles)
>     - rebase on top of lastest Linus tree
>=20
> Previous cover letter with minor update:
>=20
>=20
> Here i am not posting users of this, they already have been posted to
> appropriate mailing list [6] and will be merge through the appropriate
> tree once this patchset is upstream.
>=20
> Note that this serie does not change any behavior for any existing
> code. It just pass down more information to mmu notifier listener.
>=20
> The rational for this patchset:
>=20
> CPU page table update can happens for many reasons, not only as a
> result of a syscall (munmap(), mprotect(), mremap(), madvise(), ...)
> but also as a result of kernel activities (memory compression, reclaim,
> migration, ...).
>=20
> This patch introduce a set of enums that can be associated with each
> of the events triggering a mmu notifier:
>=20
>     - UNMAP: munmap() or mremap()
>     - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
>     - PROTECTION_VMA: change in access protections for the range
>     - PROTECTION_PAGE: change in access protections for page in the range
>     - SOFT_DIRTY: soft dirtyness tracking
>=20
> Being able to identify munmap() and mremap() from other reasons why the
> page table is cleared is important to allow user of mmu notifier to
> update their own internal tracking structure accordingly (on munmap or
> mremap it is not longer needed to track range of virtual address as it
> becomes invalid). Without this serie, driver are force to assume that
> every notification is an munmap which triggers useless trashing within
> drivers that associate structure with range of virtual address. Each
> driver is force to free up its tracking structure and then restore it
> on next device page fault. With this serie we can also optimize device
> page table update [6].
>=20
> More over this can also be use to optimize out some page table updates
> like for KVM where we can update the secondary MMU directly from the
> callback instead of clearing it.

We seem to be rather short of review input on this patchset.  ie: there
is none.

> ACKS AMD/RADEON https://lkml.org/lkml/2019/2/1/395

OK, kind of ackish, but not a review.

> ACKS RDMA https://lkml.org/lkml/2018/12/6/1473

This actually acks the infiniband part of a patch which isn't in this
series.


So we have some work to do, please.  Who would be suitable reviewers?

