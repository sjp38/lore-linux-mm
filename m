Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8935C10F02
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:57:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80F46218C3
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:57:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80F46218C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20C2D8E0004; Mon, 18 Feb 2019 04:57:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1958A8E0002; Mon, 18 Feb 2019 04:57:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05CA28E0004; Mon, 18 Feb 2019 04:57:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1708E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:57:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id j5so3276935edt.17
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 01:57:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=uUGM/73znCvwlaNjK2niLL+TaPm0SAotppy07CyK6pc=;
        b=P1qYZPlAspD0M4l21XPRJfemLt4ri5+G4+Cle1ecD2HQp2b/vvGdkMgpeP5nT4y/DJ
         FI6rP3NUNXAN7HJAS7mqZzP62tvNU5glmSyQpBdSPZY+NK9NRNMGECc1ExQnBAtA9wf9
         wq2qarulV62iBR4vvF0frYXETSfrxHfhx/De04/UQLiYkQTt+Wosv+G89gmCnGiYR+2r
         DTXdvdfO4h7yVCTtQBqPTGuGMfnPySv4792kz+j32x+AgHpNVhLcqjuCPTii/9oKs88z
         GfBvWvfhlx6gKc/oPIHbtxTUoNBUXSkAnHYSLijHG7pTjOnKAh50j2FecMZDM2ECmOEl
         CxOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuZyEjFcm0gWssosBr3VON//bnXvgusSDuZ8rgDdJA0UUO4Ot+aG
	rhBEc7vE3jQDYhdhH5AjwLODoEcfPvdsxR82hoK5NmGJKtCDRnkIeJVJa4tzNJw8coAR2cjHf9o
	qKr6DTlwFAqeNT2OenwOIrGlSeNH+FBPlq7HCOO8ipcSZ2iHLr9GgREQTLChsU9KUqQ==
X-Received: by 2002:a17:906:19c4:: with SMTP id h4mr15470027ejd.30.1550483842143;
        Mon, 18 Feb 2019 01:57:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY21Gwr0dlmbl9uu0kIzndwz/fcYxZq+XIXfhIINXIQ3BPqCwg9i0dPgWUMO8Y/TSpw9GDE
X-Received: by 2002:a17:906:19c4:: with SMTP id h4mr15469981ejd.30.1550483841197;
        Mon, 18 Feb 2019 01:57:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550483841; cv=none;
        d=google.com; s=arc-20160816;
        b=BaOxyN7y7J/n6CLL7wgd1AcHKHK8okDcAg3xwasPD+Vy6cKG3b5JnE7AQcklI4tQD+
         Q2xCHdNsOqYjNjxcj4eP2XbDIohcetOhJwIlcsr211NI+2wE0vecf+b/kYGdf0x58Js6
         +DXyxCdJx3A2KAZVwaD/ws6yAmIEptFLc+Bymg5CrR/jfZfqsHaa37ZERj0gf2lpJBoT
         55stPVqKEZ5Q/dMTydyklVE8AEkCMFYXN3ZTcXgvCHE8hruNnPAICWI56aSezFToWfoP
         rKzcywM4b89029yjDJ+MmmOs6zvT6vOEmy8eziI7T+QNYVn07xkI216WYRUkrWWy8brX
         OZLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=uUGM/73znCvwlaNjK2niLL+TaPm0SAotppy07CyK6pc=;
        b=nP9QOiFs5ivyg19B04h1eQTkr+rPG3y8SOF5nseMraR42L0e+gnUBfjsdbF9sYV1iM
         Q1Q962Rfbo8GwunVdGfrLfpD4aNMFKuFzHFseua8odVtnniEbORbCRy4pInni4HKz6el
         ukkqB2qvLiI2xIvgqz4xBo65pzkCaLw9wX9yvdIxT3PoMILxNRTqoN6VqKUnnLi6qtYy
         I1mcGtNB7BZJ1UbCTAfmzg7gAW3nMyCOA/R1SjTAq9A3ss5CpiB6nmGIWAnxHZlE5dP2
         D6+S3nX4wl7PaXsf0fLbCI7cMepC3/gXFjMqDuRl57xgN0o4zNIc6UyEnv0T32fn/8G5
         ftfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k18si2018299eda.415.2019.02.18.01.57.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 01:57:21 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 861A3ABE3;
	Mon, 18 Feb 2019 09:57:20 +0000 (UTC)
Subject: Re: mremap vs sysctl_max_map_count
To: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: hughd@google.com, viro@zeniv.linux.org.uk, torvalds@linux-foundation.org
References: <20190218083326.xsnx7cx2lxurbmux@d104.suse.de>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <a11a10b5-4a31-2537-7b14-83f4b22e5f6c@suse.cz>
Date: Mon, 18 Feb 2019 10:57:18 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190218083326.xsnx7cx2lxurbmux@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/18/19 9:33 AM, Oscar Salvador wrote:
> 
> Hi all,
> 
> I would like to bring up a topic that comes from an issue a customer of ours
> is facing with the mremap syscall + hitting the max_map_count threshold:
> 
> When passing the MREMAP_FIXED flag, mremap() calls mremap_to() which does the
> following:
> 
> 1) it unmaps the region where we want to put the new map:
>    (new_addr, new_addr + new_len] [1]
> 2) IFF old_len > new_len, it unmaps the region:
>    (old_addr + new_len, (old_addr + new_len) + (old_len - new_len)] [2]
> 
> Now, having gone through steps 1) and 2), we eventually call move_vma() to do
> the actual move.
> 
> move_vma() checks if we are at least 4 maps below max_map_count, otherwise
> it bails out with -ENOMEM [3].
> The problem is that we might have already unmapped the vma's in steps 1) and 2),
> so it is not possible for userspace to figure out the state of the vma's after
> it gets -ENOMEM.
> 
> - Did new_addr got unmaped?
> - Did part of the old_addr got unmaped?
> 
> Because of that, it gets tricky for userspace to clean up properly on error
> path.
> 
> While it is true that we can return -ENOMEM for more reasons
> (e.g: see vma_to_resize()->may_expand_vm()), I think that we might be able to
> pre-compute the number of maps that we are going add/release during the first
> two do_munmaps(), and check whether we are 4 maps below the threshold
> (as move_vma() does).
> Should not be the case, we can bail out early before we unmap anything, so we
> make sure the vma's are left untouched in case we are going to be short of maps.
> 
> I am not sure if that is realistically doable, or there are limitations
> I overlooked, or we simply do not want to do that.

IMHO it makes sense to do all such resource limit checks upfront. It
should all be protected by mmap_sem and thus stable, right? Even if it
was racy, I'd think it's better to breach the limit a bit due to a race
than bail out in the middle of operation. Being also resilient against
"real" ENOMEM's due to e.g. failure to alocate a vma would be much
harder perhaps (but maybe it's already mostly covered by the
too-small-to-fail in page allocator), but I'd try with the artificial
limits at least.

> Before investing more time and giving it a shoot, I just wanted to bring
> this upstream to get feedback on this matter.
> 
> Thanks
> 
> [1] https://github.com/torvalds/linux/blob/master/mm/mremap.c#L519
> [2] https://github.com/torvalds/linux/blob/master/mm/mremap.c#L523
> [3] https://github.com/torvalds/linux/blob/master/mm/mremap.c#L338
> 

