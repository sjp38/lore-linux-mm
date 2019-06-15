Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3984C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 22:16:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A36F21852
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 22:16:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="haA0LAFm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A36F21852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED5086B0003; Sat, 15 Jun 2019 18:15:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E84AE6B0005; Sat, 15 Jun 2019 18:15:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D74648E0001; Sat, 15 Jun 2019 18:15:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0396B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 18:15:59 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a21so4685689pgh.11
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 15:15:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:subject:in-reply-to:references:message-id;
        bh=qVs0z4bcJnss3C446YeiTW0MGtbRUrI5N4u2bVGrUEw=;
        b=gCwoeR7rdjWmDMTZBv1SZRddpJMvNUZtBt8spP9fqq6JIDmrRHGCh+2Q5K7zcD3EyY
         3dt3ARlkDy7Il+RPyOZV9eKGCaD7HcbgKf6VyqH8gHfKbE7GhNZNhs81JHmo4pCI36yx
         EyJiCNf8r5kpHWBj6OX7qlXXYJVAwgS51ULw1Up+N0gsB7tc1C363PTKniyqYBzQQFvO
         mFfgiNSQYVVPjuet+kK1d3R8vwbR9SPv+v8CmBH4d++Dl9bKSJ4Blj8GbS7wK0AFl+/l
         WvEOXUgnjSSfN63Iol41wgjN5ZPV/gTwSAT/uuAYA6gRm1urW6fRq9bwVSjSJu6ChHGP
         2oKQ==
X-Gm-Message-State: APjAAAUMJzttVUNZknjWHUP22PaacWgiV8W1NER+6/JJA3deoiPdPPz2
	/uIZ06eRVUO0TnaRQX3iKZjYq6ErjsuRJvAjNPWuw4khgMdevCc2BHrEPO9secYJXCW18VePtyS
	yMjF4OpP+lE+L2ceojV8+mW23IKkyLl06EFHbVxVc8FvNHFcxYEV2KuG3NyIco1eRow==
X-Received: by 2002:a17:902:8696:: with SMTP id g22mr74405791plo.249.1560636959267;
        Sat, 15 Jun 2019 15:15:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfkdRXBLKPlRfx/PAUVCwUEGhrQcxNrnXZab/cyrCdrJV2TNU4Z53+3bZcIJXr0ele7Xpv
X-Received: by 2002:a17:902:8696:: with SMTP id g22mr74405754plo.249.1560636958476;
        Sat, 15 Jun 2019 15:15:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560636958; cv=none;
        d=google.com; s=arc-20160816;
        b=rAfUr2s/UvrfnxaVGxAK5l5OTjaWp5058w1q3NV9wMJZFTROpfDHNOSbx9NsTU7ITT
         Bicx/KAKrhLyPeNEc0PX0wotGiZyMQ6HmMb4Bifb2uzLlqjVwd2ToTeb5GGsHfpzT9jW
         eAjhOMq+CEytbx0a1yH4+mjkOlmQOHY9+8S53PEM245UzA6E3HmArcVVRO3Fbg+Tq3rf
         fM7RufnjwJHvf2VUXllsR76lmNesD3UTz4L5J+ymBCUxLKOC8evvv/fb/K34WTvd+w9u
         fSVSGEgu/Rd8BMmM0He+h2huO117/tP9vG2TbaMjd/vGvv8UJCMp2bk4MZZL9oQhPmFN
         Hfjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:cc
         :cc:cc:to:to:to:from:date:dkim-signature;
        bh=qVs0z4bcJnss3C446YeiTW0MGtbRUrI5N4u2bVGrUEw=;
        b=S4W9ilUYyOK2h4UGij1UYwor++5c1FsFe0tfD/BnRnqT48jhKrdMS0/Ocey5fxjpSD
         dYCRlTXuThyBDaO1vCKJxLWiNr/J0wRZ7hxx/cQe3jzHnulrRFtENgYdPRWF4XKcabUv
         3OKkhtmCJT8UAg7bMpcH/8i329HZD68d1qfPOQsXM9Qzv6lnONPauxxP4ptqTHiIoHZY
         wJPyerBN0kIRXVjPlV8jrJ9eA+CTAqYOwmdaMhlkE5AjNYAWsfoiqypDAlKvmCInYf9q
         QjurQoL8X7OswTn0F9B64fh+lzfvtZNmM6bQ1xkIoT+xzviYBcci82PHEHzJjj7tTQ5N
         OoRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=haA0LAFm;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x8si6100881pfa.186.2019.06.15.15.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 15:15:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=haA0LAFm;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CD1492183F;
	Sat, 15 Jun 2019 22:15:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560636958;
	bh=j8f0RloDwLFUB9yV8LiUghVVVhP99L+VwIpbEFJafBc=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:
	 In-Reply-To:References:From;
	b=haA0LAFmfP0eUI79IrTD1kcwsuY3XV16XEKhfIM0T/ozFcHn+yzmdlBZqs5qrWGkE
	 XXxnv8boomR0t3g8GctruAJeP+EZqZkNDHSa6S7em3Ia+kBfT3MIRI+GSYIPaN2ndw
	 tc4Zc26Yszp4+WkxlpZNmA3rkb0bIiXl3x/G8g5Q=
Date: Sat, 15 Jun 2019 22:15:56 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Nadav Amit <namit@vmware.com>
To:     Andrew Morton <akpm@linux-foundation.org>
Cc:     linux-kernel@vger.kernel.org, linux-mm@kvack.org,
Cc: stable@vger.kernel.org
Cc: Borislav Petkov <bp@suse.de>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH 1/3] resource: Fix locking in find_next_iomem_res()
In-Reply-To: <20190613045903.4922-2-namit@vmware.com>
References: <20190613045903.4922-2-namit@vmware.com>
Message-Id: <20190615221557.CD1492183F@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: ff3cc952d3f0 resource: Add remove_resource interface.

The bot has tested the following trees: v5.1.9, v4.19.50, v4.14.125, v4.9.181.

v5.1.9: Build OK!
v4.19.50: Failed to apply! Possible dependencies:
    010a93bf97c7 ("resource: Fix find_next_iomem_res() iteration issue")
    a98959fdbda1 ("resource: Include resource end in walk_*() interfaces")

v4.14.125: Failed to apply! Possible dependencies:
    010a93bf97c7 ("resource: Fix find_next_iomem_res() iteration issue")
    0e4c12b45aa8 ("x86/mm, resource: Use PAGE_KERNEL protection for ioremap of memory pages")
    1d2e733b13b4 ("resource: Provide resource struct in resource walk callback")
    4ac2aed837cb ("resource: Consolidate resource walking code")
    a98959fdbda1 ("resource: Include resource end in walk_*() interfaces")

v4.9.181: Failed to apply! Possible dependencies:
    010a93bf97c7 ("resource: Fix find_next_iomem_res() iteration issue")
    0e4c12b45aa8 ("x86/mm, resource: Use PAGE_KERNEL protection for ioremap of memory pages")
    1d2e733b13b4 ("resource: Provide resource struct in resource walk callback")
    4ac2aed837cb ("resource: Consolidate resource walking code")
    60fe3910bb02 ("kexec_file: Allow arch-specific memory walking for kexec_add_buffer")
    a0458284f062 ("powerpc: Add support code for kexec_file_load()")
    a98959fdbda1 ("resource: Include resource end in walk_*() interfaces")
    da6658859b9c ("powerpc: Change places using CONFIG_KEXEC to use CONFIG_KEXEC_CORE instead.")
    ec2b9bfaac44 ("kexec_file: Change kexec_add_buffer to take kexec_buf as argument.")


How should we proceed with this patch?

--
Thanks,
Sasha

