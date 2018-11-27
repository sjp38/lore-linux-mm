Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 161806B464B
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 01:57:33 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a18so9419894pga.16
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 22:57:33 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g92-v6si2943123plg.354.2018.11.26.22.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 22:57:31 -0800 (PST)
Date: Tue, 27 Nov 2018 06:57:30 +0000
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH 5/5] userfaultfd: shmem: UFFDIO_COPY: set the page dirty if VM_WRITE is not set
In-Reply-To: <20181126173452.26955-6-aarcange@redhat.com>
References: <20181126173452.26955-6-aarcange@redhat.com>
Message-Id: <20181127065731.5B98821104@mail.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.orgstable@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 4c27fe4c4c84 userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support.

The bot has tested the following trees: v4.19.4, v4.14.83, 

v4.19.4: Build OK!
v4.14.83: Failed to apply! Possible dependencies:
    2a70f6a76bb8 ("memcg, thp: do not invoke oom killer on thp charges")
    2cf855837b89 ("memcontrol: schedule throttling if we are congested")
    fa27dfd489b9 ("userfaultfd: shmem: add i_size checks")


How should we proceed with this patch?

--
Thanks,
Sasha
