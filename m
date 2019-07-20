Return-Path: <SRS0=pjJT=VR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FFC3C76188
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 12:23:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 081B1217F5
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 12:23:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1f9sl2Bc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 081B1217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5B6A8E0001; Sat, 20 Jul 2019 08:23:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E5796B0008; Sat, 20 Jul 2019 08:23:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85FD88E0001; Sat, 20 Jul 2019 08:23:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA0C6B0007
	for <linux-mm@kvack.org>; Sat, 20 Jul 2019 08:23:33 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d190so20325166pfa.0
        for <linux-mm@kvack.org>; Sat, 20 Jul 2019 05:23:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:cc:subject:in-reply-to:references:message-id;
        bh=RuIfP/Kyd5QUstidhHOXhVTrHF1M8Ek8CzX8iyB4Wu4=;
        b=Xyb6e8kmdMnPx6uXNquI0CRhgZUxPZ1XlYTdGlNDfZSWztHK+SFrv+YCevQzVv3uUy
         QaRH2+4KXp4yvEMeISps64wJdRuK4/vGTkdZTEH+r4AhqaQvs2/Jj3lWQaI6vdGLkmf4
         GTd2Jzjcq3l88VWqj0SKIH4rkHYMF7spskreZSbLtHFReqnYHRY2gU/MH79sEJP73FVP
         eimvLz4BVg2RanQT3U44rj/UIlPSKunC8xSSSF7xnBeyX+GgOOFMit02ekDZG4/bzAgO
         3BPrMFqkQh7Roinrs8G3Nes1c0VIrPRM0gXZQi7cB31vYjbTsdeYoOQplAT/WlT6OCFh
         wVRw==
X-Gm-Message-State: APjAAAWlJ+hx2QZ4R/dHmTVWoYdh1aWWAYyMGCy6STJ8+aJmHKzLDdHZ
	Zxzy4qKlZAgQdfkTu5T5YMe6JMU9D6E45m/vko6puhVvPECKabAG+lnYrJeLjhdbK5p4pSK4IRd
	jMbP+riWzPnrmPIAPH59lv/1aCzW2JHw7+U1MXqp1GIe4VZ5ORw6HX0VFnu1kc8lMWA==
X-Received: by 2002:a17:90a:80c4:: with SMTP id k4mr64614002pjw.74.1563625412936;
        Sat, 20 Jul 2019 05:23:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCYeNVp5Efy9X1r9Xsssb+xJo1wz4/8GHAzTlynhksfLad8k5KTovB2giURrm/uiSGbA4v
X-Received: by 2002:a17:90a:80c4:: with SMTP id k4mr64613950pjw.74.1563625412284;
        Sat, 20 Jul 2019 05:23:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563625412; cv=none;
        d=google.com; s=arc-20160816;
        b=jUINVkMcM95I4uD90q6d503ACg7k5cw6jY+rxzGBPFMWF7zm99venu37FcdbenvhYQ
         ixHjTEvbnd5hDd1OwdhwH6Gl70BDN0Wujsl1Pfooiu1LopVcW5QuMxUcHHnouf4DtmDP
         d23ZtMZ+7XJCZQ5RBrV7iGzyOFJb5qrItGc3ufAiXB7A1jvq6VntCcWuzblgD9r008iv
         CVtmWrveZjU9DnK4sJ9oCfZXpkFOd14wgDpKHyJdGFk+DU8qIANTU+nJ/gZNtHTvwGAo
         XrDv4ME+opk3z5e7ZiBi2m4fa+rqpk+LO9g5Fb7m48pEMhPHtzVmsu+2mq+UX8Aabjao
         cUIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:cc
         :to:to:to:from:date:dkim-signature;
        bh=RuIfP/Kyd5QUstidhHOXhVTrHF1M8Ek8CzX8iyB4Wu4=;
        b=BeJ2xjX4OA/HIL1BQ5nuQrvvr77lP6ghrgVACjYiHPuVd+YLfiCoQPr5SNhsAIID2+
         efRF0DXK3YXEbjSDXo6lmsUkGeQDwQ3vN8/vAEqQj1IE9Gizb4Bu08q7yjpdW1Yw5eqs
         1cmNUDfrusa2j2bxf49EmnIOZHiUl0cmbfplo9Hi00Ap2geQKMKusZGbZstbkYxn5DtQ
         FGpvE7dRJsPTg2s6frVEbnkuLC6B303mE5pZlmBhO8neoLA2Tw8A1/oTYYcUB2eJGMdy
         8VU2OCo1EBHF9kDtbuTgR1QpmcXJIhgWKOsKi3tRZgibvMlb2H3t/RXZiRcXUG551OSx
         UgqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1f9sl2Bc;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a17si4780996pfa.45.2019.07.20.05.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Jul 2019 05:23:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1f9sl2Bc;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B01E62184E;
	Sat, 20 Jul 2019 12:23:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563625411;
	bh=aInrbX5qxpHP++gY/qZsLEvnaPPN4DnxOPIFesgSYyI=;
	h=Date:From:To:To:To:CC:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:In-Reply-To:
	 References:From;
	b=1f9sl2BcRksQPo14VWRZ8RE/XxOR0pLdqC0oeSSywvZlNmBTJb8ctxqKi53CkPdtP
	 X65QU3MUhNKzwTdhQZQTRL+K2b5eH3MBusw+69x11fAkDaQ6O/MEUFRg0PHW3yqJo7
	 ra14Dgn6JPe4ihzJECEtJxCwGrz56K/KxbsBDuXA=
Date: Sat, 20 Jul 2019 12:23:30 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: <stable@vger.kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH v2 3/3] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
In-Reply-To: <20190719192955.30462-4-rcampbell@nvidia.com>
References: <20190719192955.30462-4-rcampbell@nvidia.com>
Message-Id: <20190720122331.B01E62184E@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: a5430dda8a3a mm/migrate: support un-addressable ZONE_DEVICE page in migration.

The bot has tested the following trees: v5.2.1, v5.1.18, v4.19.59, v4.14.133.

v5.2.1: Build OK!
v5.1.18: Build OK!
v4.19.59: Build OK!
v4.14.133: Failed to apply! Possible dependencies:
    0f10851ea475 ("mm/mmu_notifier: avoid double notification when it is useless")


NOTE: The patch will not be queued to stable trees until it is upstream.

How should we proceed with this patch?

--
Thanks,
Sasha

