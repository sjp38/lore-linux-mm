Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40CB3C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 22:04:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5812218A3
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 22:04:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5812218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EE4A8E0003; Tue, 26 Feb 2019 17:04:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29D368E0001; Tue, 26 Feb 2019 17:04:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B5338E0003; Tue, 26 Feb 2019 17:04:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8D298E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 17:04:32 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f10so10572617pgp.13
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 14:04:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+FmWNgdPrQkIgwjjkZm438VDy4/G80EYKEL6gE97x4o=;
        b=poIkF+4qMvmQq0m62KlBL6AHN+9HWgTl1OoXL1VO4VlvxFcgtPwNytc5ayrpPg/tnv
         EEN6UwN+/1y3lQFb8VkV/IVqMqUC83hPanldbPAktUVtPM8tBXLGXTx3XT1pSuMbdPc4
         btSrBp5bnftGAOcYk9+3yf7tkzvozkXR54uOZpnSEkqFPO40VSnVSjmd22p+4vNvow3x
         bPu09Jxa0r6X2wu2lGw9Ihbm+Mo9Fj6YmIaP1aPIbM06pUWtc4hdRdmCAam3YyPQr0V4
         x2BoXxOiy0hDhiZklY4VI1xK1RkNhB7L/CGl2pr/V7VmvdyE+9OtkUXRFZBfAE3YnXQN
         uFWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAubaqv/thK60/M+tmksouksApCU3d8qg9teBqNLedDh8xhFzh7Qe
	8reCpz6aYr6zcLNLIeFOVcfn5mSPnfrgTDkQqKavPRcjM0I/j2VO6cFKuQljNjVUyiiZ2xgHcyv
	JjmmhH1hHly5c5gFK5sMztS7GhD880OH2lfbdk/VPdMLQlMO/IckLsf3cogNxfnQ3SA==
X-Received: by 2002:a63:54c:: with SMTP id 73mr26136399pgf.295.1551218672381;
        Tue, 26 Feb 2019 14:04:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYP01NGRcIDLo6invxqyZIHlmMCCB8Hfy+wW6zwKe0uFdHYAmuyOtYoa1xLGZ3pSj7VZy5a
X-Received: by 2002:a63:54c:: with SMTP id 73mr26136324pgf.295.1551218671287;
        Tue, 26 Feb 2019 14:04:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551218671; cv=none;
        d=google.com; s=arc-20160816;
        b=YPGN8b+42O3Tu8lnxIKNOm2aQV601d7anlszyYKu8hcuI0A1cHFTNNqCSD90AO2xm6
         ds3jyVNwrA1g7W4tX5RwFqO8zzwqZ87DggdIKWSSsl0LQfnWWC1fqhD+vIv3u+MIvwVd
         b6TWlhqw2cE56aWDon3Vs+y4U9f5QV7E3oNC8IYIuMpRO8IxQPolkYqQgqjz6lZEmztL
         pmLNYqy2YE34+VEb76nj5RirMIz1K0GB5DgGHgaeUX3idCn8dHW9jDqweFMMeLR555/X
         S/T1/HKJJbnDmILvf3BlaNCxu20HfOh1giGcI2DCz5GBhCRmvb6kbvIctSZGBKMKZKVB
         iFoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=+FmWNgdPrQkIgwjjkZm438VDy4/G80EYKEL6gE97x4o=;
        b=EoJmv0b0rMDN4M9n1sYMcJo8d0ASVm+dKv9rmgmh29pzWAIZNmXEwe6Oic+P+Shdg4
         4vaxYoGiHmXYk36MKyGmmaxGYBit5KzR0EmvDHLOXiYJ9fvSxoI2LeUMlJvI3YXC1Nsi
         a8yFgE+6HNYqbFlHi19XdpEnvOrEzKBQKsG368i4gC2677SZU9VA8ZWOzJ3K+EsQffti
         CSoNyhm6w5nxIPXevLDcmQnT/0rMtiDMDklAWKImOUy1oA/gopX0VQBopiyfSo+uprz1
         5h7IpuHkP/E5IecpAbOGVuIMeoqfJ1P6FC+rXCqvjrYYMQV3ffEl9XyKTmLmgEFlbS3r
         8PtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o24si13117624pgh.114.2019.02.26.14.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 14:04:31 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 8645D8251;
	Tue, 26 Feb 2019 22:04:30 +0000 (UTC)
Date: Tue, 26 Feb 2019 14:04:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-api@vger.kernel.org, hughd@google.com, kirill@shutemov.name,
 vbabka@suse.cz, joel@joelfernandes.org, jglisse@redhat.com,
 yang.shi@linux.alibaba.com, mgorman@techsingularity.net
Subject: Re: [PATCH] mm,mremap: Bail out earlier in mremap_to under map
 pressure
Message-Id: <20190226140428.3e7c8188eda6a54f9da08c43@linux-foundation.org>
In-Reply-To: <20190226091314.18446-1-osalvador@suse.de>
References: <20190226091314.18446-1-osalvador@suse.de>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2019 10:13:14 +0100 Oscar Salvador <osalvador@suse.de> wrote:

> When using mremap() syscall in addition to MREMAP_FIXED flag,
> mremap() calls mremap_to() which does the following:
> 
> 1) unmaps the destination region where we are going to move the map
> 2) If the new region is going to be smaller, we unmap the last part
>    of the old region
> 
> Then, we will eventually call move_vma() to do the actual move.
> 
> move_vma() checks whether we are at least 4 maps below max_map_count
> before going further, otherwise it bails out with -ENOMEM.
> The problem is that we might have already unmapped the vma's in steps
> 1) and 2), so it is not possible for userspace to figure out the state
> of the vma's after it gets -ENOMEM, and it gets tricky for userspace
> to clean up properly on error path.
> 
> While it is true that we can return -ENOMEM for more reasons
> (e.g: see may_expand_vm() or move_page_tables()), I think that we can
> avoid this scenario in concret if we check early in mremap_to() if the
> operation has high chances to succeed map-wise.
> 
> Should not be that the case, we can bail out before we even try to unmap
> anything, so we make sure the vma's are left untouched in case we are likely
> to be short of maps.
> 
> The thumb-rule now is to rely on the worst-scenario case we can have.
> That is when both vma's (old region and new region) are going to be split
> in 3, so we get two more maps to the ones we already hold (one per each).
> If current map count + 2 maps still leads us to 4 maps below the threshold,
> we are going to pass the check in move_vma().
> 
> Of course, this is not free, as it might generate false positives when it is
> true that we are tight map-wise, but the unmap operation can release several
> vma's leading us to a good state.
> 
> Another approach was also investigated [1], but it may be too much hassle
> for what it brings.
> 

How is this going to affect existing userspace which is aware of the
current behaviour?

And how does it affect your existing cleanup code, come to that?  Does
it work as well or better after this change?

