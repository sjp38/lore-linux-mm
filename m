Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4A44C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A745E2175B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A745E2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33EEC8E0002; Tue, 29 Jan 2019 11:54:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EDB98E0001; Tue, 29 Jan 2019 11:54:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DEB98E0002; Tue, 29 Jan 2019 11:54:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E11778E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:39 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 42so25058292qtr.7
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=6qZJ9FGK6M6T3WrHuVkIvc+3dyZ5WXldhn9HnJDuq/A=;
        b=Kctpwk0anvQLmlatj4SI01pDSc+UIXGtmcVEnyBGSx3SKPFW+xDPo1ZsvdD2MS1wng
         x8hqkESA6Hj/ekVViUEW9kpmEZ+dkP8X6kfJQmeDfCP0ux3yA/Lg7oFGsRMUtS3fOhpk
         i+MYNOZbLnSXRAS1PeU72zD5UPu5RAtn9XHf1mSBZJ6xanMVO/1ooLTWA/EfJ/CCR3lR
         q9hDoxJCeaC6wRvTjlra85W700wM33eE10P2dMJdvKO5wVtdhC7slbZYbAQ67DkpxTfP
         PdQps3fSHMXGhZ0wKPuzIwhBS2hTIVO0TmvB6bhmkOXEuiPGKu0UH5psrerpH7sI2RdV
         b0rA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfaeHlUIIQP+2v2hmPlJ6PdBTYwoGXEtpHdD1ifqGZwhtZC7Cw8
	dK28V1/KvK50+IVqzGxX5uTmGp8IhEwzsTggMWWhanGWja6IJiqpViyylpUNf+lHX9ByIbFhgin
	hhtNCXhwq6b9CKzLfnm5Qw/PPRXxqOmlDHYQRSs+SeEY76mZwvqd/2GlwW0FrWt0Ovw==
X-Received: by 2002:a37:6352:: with SMTP id x79mr23890645qkb.52.1548780879678;
        Tue, 29 Jan 2019 08:54:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Vplmh0SKuMHQoR2i0TkOwcfzzkOX8F7YYnPACMQDL7WbQ3MGEvOrOg6XpKejWCeg8KFPF
X-Received: by 2002:a37:6352:: with SMTP id x79mr23890612qkb.52.1548780879131;
        Tue, 29 Jan 2019 08:54:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780879; cv=none;
        d=google.com; s=arc-20160816;
        b=LMZEPCgyhzA/K1SLcBqEPD7Sp3oTFfgVoJsXK6bTYqsZrBomBRH7Z7V/b0azYl9NmP
         2qwjwC3QKUdMuRgcXYPQfFJXTS5P/8NUVYlGAbjohhamoHn6Qq/HAxJl8pZKm/sD8Qf4
         wsPKV+ahMZtIgWkavW6fBCTdgmvj+o6UsWwEUJSz5v5BMw1Y/Pk4Tuaf3KwAgur3mi8M
         kwCeB7b9atqMimQuElz2lMU+gHTROYHqOQvHAoiWR7VGdXzLmm7EmBx02/hBpT42oJNv
         yj2qfQP6/z7AN2gzaR5teYQEoR0EIXAfKNhTnZRj0IbuKQBK/vqQVO14F7nnVvtuq9PM
         lZMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=6qZJ9FGK6M6T3WrHuVkIvc+3dyZ5WXldhn9HnJDuq/A=;
        b=Tw6y8zU5IvKNuss78zsrGCHYakWB3osfGkY0BQwSniR7gQWKPDA5uakjbWOaJ6oV99
         QAjGB5JwwrlL+hOOmcumd1nUZlrw/F9hkliK8Pydfac5ik3G3mtm3QVM12dDMSbZhYHp
         qL5hCLz8fv9/z3Qw+JY92N6uy3yJmntyfeR+LrtfEcIf6qETUyYQfasVOVQ7+5qi0mwa
         EQitSVJwO/UkrGfwFJvp5tuIquLwz2Y05EcvJ+XB3bUz1FQyfjk5RC04MEF8ZLDHPXEf
         4ByOLic9+5N257Tuyyyphpa7kwcdOeaZAF2wixBDp9eq9kJBM7ibybzoRWPT08JSrNZU
         uAfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t64si1705792qka.35.2019.01.29.08.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2D4CA81F09;
	Tue, 29 Jan 2019 16:54:38 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9E319102BCEB;
	Tue, 29 Jan 2019 16:54:36 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 00/10] HMM updates for 5.1
Date: Tue, 29 Jan 2019 11:54:18 -0500
Message-Id: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 29 Jan 2019 16:54:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This patchset improves the HMM driver API and add support for hugetlbfs
and DAX mirroring. The improvement motivation was to make the ODP to HMM
conversion easier [1]. Because we have nouveau bits schedule for 5.1 and
to avoid any multi-tree synchronization this patchset adds few lines of
inline function that wrap the existing HMM driver API to the improved
API. The nouveau driver was tested before and after this patchset and it
builds and works on both case so there is no merging issue [2]. The
nouveau bit are queue up for 5.1 so this is why i added those inline.

If this get merge in 5.1 the plans is to merge the HMM to ODP in 5.2 or
5.3 if testing shows any issues (so far no issues has been found with
limited testing but Mellanox will be running heavier testing for longer
time).

To avoid spamming mm i would like to not cc mm on ODP or nouveau patches,
however if people prefer to see those on mm mailing list then i can keep
it cced.

This is also what i intend to use as a base for AMD and Intel patches
(v2 with more thing of some rfc which were already posted in the past).

[1] https://cgit.freedesktop.org/~glisse/linux/log/?h=odp-hmm
[2] https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-for-5.1

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Dan Williams <dan.j.williams@intel.com>

Jérôme Glisse (10):
  mm/hmm: use reference counting for HMM struct
  mm/hmm: do not erase snapshot when a range is invalidated
  mm/hmm: improve and rename hmm_vma_get_pfns() to hmm_range_snapshot()
  mm/hmm: improve and rename hmm_vma_fault() to hmm_range_fault()
  mm/hmm: improve driver API to work and wait over a range
  mm/hmm: add default fault flags to avoid the need to pre-fill pfns
    arrays.
  mm/hmm: add an helper function that fault pages and map them to a
    device
  mm/hmm: support hugetlbfs (snap shoting, faulting and DMA mapping)
  mm/hmm: allow to mirror vma of a file on a DAX backed filesystem
  mm/hmm: add helpers for driver to safely take the mmap_sem

 include/linux/hmm.h |  290 ++++++++++--
 mm/hmm.c            | 1060 +++++++++++++++++++++++++++++--------------
 2 files changed, 983 insertions(+), 367 deletions(-)

-- 
2.17.2

