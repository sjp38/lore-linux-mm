Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D88B1C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:12:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EE8620857
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:12:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EE8620857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FEDD8E0004; Tue, 29 Jan 2019 04:12:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AD8C8E0002; Tue, 29 Jan 2019 04:12:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A1628E0004; Tue, 29 Jan 2019 04:12:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C24BC8E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 04:12:27 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so7740937ede.19
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 01:12:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=E6few/QoKUbhLkKQPPeCYsGIS/dOtUzP5KGPTeUJWAE=;
        b=fW0nwQKupqI6VASd/Z5l7EVwsAz1ngdVuAW88x8ezct5mcgmcQ2mMFNBwd5+cmcRQE
         ELLujfvdhJnHNmPEN6kHngjHoZJW/gTENuJUi9kFdiEKLT0PmOPDy8pdpGBiPK8TUPor
         +UVUIiVxCTK4bWeNgoSJFlP6DjcTYvzMAU5CjW/1IHvKxtDJu0ZDfKvGxIEnik8Iqe8k
         L1qm7cSI2lEIEWyZU3re/6h7EZRsYeX+QZnvJsc3fEfNFs3Np65urqRkiwj+Qc+JVBPl
         ICwwdPExXEMQF8iCjlg7TggqqU3ikahGs03Uul/TBm4XxvsO543CTW0tchlwLkgSL0i5
         3yKw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukep/iwxEJ2BwYhICACTPx4x7WivPa52sudMAEKyOan2PVciLAcn
	dGdgpcyJ59CYAgB+/dBYnpbNKrUxtzOFlf1Z3+LToI0GcEAfb6akPkHjr+eR08lNUEaSYoCZ0z9
	t2vujQdwYZBwUITNTe/IslCR9v9QFgfb12rpQ2+GBF97S2qGRl6Bwffij4mxgwrU=
X-Received: by 2002:a17:906:8311:: with SMTP id j17mr20460080ejx.178.1548753147281;
        Tue, 29 Jan 2019 01:12:27 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5BzaSjhxMsPYzsoy7OaTKu2pWr/H4KMcU9MUvmfpSO6evgI8lnQI0AXYUqiOQS2DB5x5xx
X-Received: by 2002:a17:906:8311:: with SMTP id j17mr20460056ejx.178.1548753146525;
        Tue, 29 Jan 2019 01:12:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548753146; cv=none;
        d=google.com; s=arc-20160816;
        b=bremlvcTtDCzRNBrQkpdtLduQbYupjluCXxGjY1lcnzi7YiMnp/iBkef/ZEfdIhYgI
         OPIdvd23meXWFdE5dYtOPn24CHCNfPK9FtowCki2liV0LczSFfu6Il1j0B4Ap3x/Rnlt
         5JD9R86Y3EeayN61c1o34OCTgy8crGS9EbepKOcK8Wc5RlTmpcyNkqxAGqQxhms0XMuW
         XDYQqSeThQFEwbrwLmz2dln5otH1Uc/KUedTpxZBNFCK1+5zxZsqWL0ZIafsMk5ZNlR7
         7SC9c9C4bbrYABVj3mu4DtL3A7j7gU26cCSyhAEMt5CR6MDnX3rQpFNMD0Q+11n5DOBV
         FsKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=E6few/QoKUbhLkKQPPeCYsGIS/dOtUzP5KGPTeUJWAE=;
        b=qgI2Z/aU2JgG/TcoVavYXNwfC1ifkyhRj9yFbQio14ulL1QiN4onk3jub6YCdiK1lZ
         fGzodIdelOgzyLX/az5IjveqRz7YUmmtzd6UXEifFGmnj+/S77/JwM7yT4SK81y9kadV
         adHoFFE/NJT+L/4Bg2ABYO2yRjbcScvwvoAyNPomvBFWluLUfP7MRUxi5q1PM9vUobfV
         ZKUEK6/V8+rgUsBosnaUwwHDeW73Zm0Nrb2DwhxP1LiRwhver6p5IzJEk9DoekFPdixN
         BdkcD4EtU948bO/2EZDAr8UxUn/5MlQ8VOw9hbCL2We9LmqDpU4Bt5upDv9XPKBE2kti
         nq5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x52si405479edx.285.2019.01.29.01.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 01:12:26 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A5D9BAE89;
	Tue, 29 Jan 2019 09:12:25 +0000 (UTC)
Date: Tue, 29 Jan 2019 10:12:24 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: is_mem_section_removable do not
 pass the end of a zone
Message-ID: <20190129091224.GG18811@dhcp22.suse.cz>
References: <20190128144506.15603-1-mhocko@kernel.org>
 <20190128144506.15603-2-mhocko@kernel.org>
 <20190129090605.lenisalq2zxtck3u@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129090605.lenisalq2zxtck3u@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000052, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 29-01-19 10:06:05, Oscar Salvador wrote:
> On Mon, Jan 28, 2019 at 03:45:05PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Mikhail has reported the following VM_BUG_ON triggered when reading
> > sysfs removable state of a memory block:
> >  page:000003d082008000 is uninitialized and poisoned
> >  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> >  Call Trace:
> >  ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
> >   [<00000000008f15c4>] show_valid_zones+0x5c/0x190
> >   [<00000000008cf9c4>] dev_attr_show+0x34/0x70
> >   [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
> >   [<00000000003e4194>] seq_read+0x204/0x480
> >   [<00000000003b53ea>] __vfs_read+0x32/0x178
> >   [<00000000003b55b2>] vfs_read+0x82/0x138
> >   [<00000000003b5be2>] ksys_read+0x5a/0xb0
> >   [<0000000000b86ba0>] system_call+0xdc/0x2d8
> >  Last Breaking-Event-Address:
> >   [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
> >  Kernel panic - not syncing: Fatal exception: panic_on_oops
> > 
> > The reason is that the memory block spans the zone boundary and we are
> > stumbling over an unitialized struct page. Fix this by enforcing zone
> > range in is_mem_section_removable so that we never run away from a
> > zone.
> 
> Does that mean that the remaining pages(escaping from the current zone) are not tied to
> any other zone? Why? Are these pages "holes" or how that came to be?

Yes, those pages should be unreachable because they are out of the zone.
Reasons might be various. The memory range is not mem section aligned,
or cut due to mem parameter etc.

-- 
Michal Hocko
SUSE Labs

