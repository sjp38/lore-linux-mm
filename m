Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0276B464D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 01:57:35 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id u20so11156342pfa.1
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 22:57:35 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m38si2998289pgl.125.2018.11.26.22.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 22:57:34 -0800 (PST)
Date: Tue, 27 Nov 2018 06:57:32 +0000
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH 4/5] userfaultfd: shmem: add i_size checks
In-Reply-To: <20181126173452.26955-5-aarcange@redhat.com>
References: <20181126173452.26955-5-aarcange@redhat.com>
Message-Id: <20181127065733.83FBA208E4@mail.kernel.org>
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


How should we proceed with this patch?

--
Thanks,
Sasha
