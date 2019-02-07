Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04ED8C282C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 13:36:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF22B206DD
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 13:36:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF22B206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 406D48E002C; Thu,  7 Feb 2019 08:36:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B6FD8E0002; Thu,  7 Feb 2019 08:36:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A6458E002C; Thu,  7 Feb 2019 08:36:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C4D1E8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 08:36:26 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so4421246edd.2
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 05:36:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/Z1iSj7n4eE2MJ/9xe6rCBS/CDY1VH3vB2iW9S3+laA=;
        b=RSyEUyCuSEaUPHCMTQvsMAOq9aJu2/xDpJ/g8Z6OT5Sgq9VMOjMEjPhmpuIRLGMx/A
         nkbMbXfszrrcXEP45l4sIhxvVlOtEdX2P3feDjE0ZD8bgZmdQ5OUDhevJkj1z2FoEE9y
         ChIBrin0wZyRPYcC5jC7XByKrXEzvqHETVqRuzFp7bVcdo53WHLl7yY1LhN6+4Q8Tr5/
         bJFe9iDg53RV7qyE/OZ+sGcovb9EDUDM+ikjBC9sI7738N9vRMxDmDZDqX0tf9OWHK8X
         4Fa3JWqXZTMPONymitk6DXEEMoNb20/rRJCfGHY6Rp7imNo/B3HHuSZFTkJaZgF/o3HL
         zzdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuZI7HeGCFqHGpQFuDbY9g2JOrfT9nUqCJApOPxUZKkSufFru5aE
	Q7HgdLqBQ1xy91n1Uokr5KvY4p4J1rbn+QYDieIG2ef18Q4h5wTJs7YPgUih1zqU1tV8nfq9+ZQ
	XJRYmnnTZeIP9VinIAFBb2IXTDYsUnYP4bApXPF7SNflrKyhsKlrNlfHgfMBnvXzrhw==
X-Received: by 2002:aa7:d5c8:: with SMTP id d8mr9961249eds.275.1549546586265;
        Thu, 07 Feb 2019 05:36:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYjuFjrA2M9o6lD9fmrhtM5fVo/ykRxZz/I0HjCbzaMd4bNVaGFbFPonIdBkpcjHMS66iFa
X-Received: by 2002:aa7:d5c8:: with SMTP id d8mr9961191eds.275.1549546585370;
        Thu, 07 Feb 2019 05:36:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549546585; cv=none;
        d=google.com; s=arc-20160816;
        b=HqTQ9SUChJwdR0GTNyFQhD8/ksR7RPshUDKxtdtgvsapMKKj0n9nl+L9UYrVR9mFjt
         EYzUQeV+BaOCCsyLHRE0g4jYpdfUJ8Wo6++ZF4WB5cpQ+SWvJyjBupy2Sot/275uqp9y
         lBGfaAeJs07RfhTI+7zke6JsENUkS+a5QaZuCMBTVFaJzJ9J0SKCuCkBQK6XWDATkCRG
         Y0IcbAjdECIs7WKX+v2Pe/rA7uw20w3eLs/W+rVB51WhlHqE2oOGCOO/RvqwXsm83sUz
         U6Oxz+NpjR6WkQ3cRTPaC1IsTQ0MqR4xncH4kNuQcadxAg2OmkC0G2FFB4dhE1J1Ot71
         mvvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/Z1iSj7n4eE2MJ/9xe6rCBS/CDY1VH3vB2iW9S3+laA=;
        b=Y8Q0/2Ifg5kjLIpw135wUp/3cEI+Vv4ufZH0f96I6tdorCTx46o0cesMQTUSOHWsga
         CofxnCKPTBfxYPbqhDkEmwdM4n3SYrfE1KQVRDT8uLLpVXRp5YUIM89NnVHS3agQ8+WP
         juiaW07GIjZBfGqCbuEW2cHx8Yo4/24GkhWlKGH/SZ86k91ikDUdhy3mHzdAwQ2s90rb
         bqv4O8iiCNKxeCUVwtTtsqt6JbYrHLSYy370JKXqotMEjFS7nBCSwtcVPcncwhAx/Ei+
         IXtmjKUJHLcRbV0GFVukchduVvlRZliPEVXoWTkSzaz7hjXn5o4U9XO1U5MjwEfJ5LFk
         26RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id z7si1037481edl.231.2019.02.07.05.36.25
        for <linux-mm@kvack.org>;
        Thu, 07 Feb 2019 05:36:25 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 8B21B41A4; Thu,  7 Feb 2019 14:36:24 +0100 (CET)
Date: Thu, 7 Feb 2019 14:36:24 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, rafael@kernel.org, mhocko@kernel.org,
	akpm@linux-foundation.org
Subject: Re: [PATCH] mm/memory-hotplug: Add sysfs hot-remove trigger
Message-ID: <20190207133620.a4vg2xqphsloke6i@d104.suse.de>
References: <29ed519902512319bcc62e071d52b712fa97e306.1549469965.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29ed519902512319bcc62e071d52b712fa97e306.1549469965.git.robin.murphy@arm.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 05:03:53PM +0000, Robin Murphy wrote:
> ARCH_MEMORY_PROBE is a useful thing for testing and debugging hotplug,
> but being able to exercise the (arguably trickier) hot-remove path would
> be even more useful. Extend the feature to allow removal of offline
> sections to be triggered manually to aid development.
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> ---
> 
> This is inspired by a previous proposal[1], but in coming up with a
> more robust interface I ended up rewriting the whole thing from
> scratch. The lack of documentation is semi-deliberate, since I don't
> like the idea of anyone actually relying on this interface as ABI, but
> as a handy tool it felt useful enough to be worth sharing :)

Hi Robin,

I think this might come in handy, especially when trying to test hot-remove
on arch's that do not have any means to hot-remove memory, or even on virtual
platforms that do not have yet support for hot-remove depending on the platform,
like qemu/arm64.


I could have used this while testing hot-remove on other archs for [1]

> 
> Robin.
> 
> [1] https://lore.kernel.org/lkml/22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com/
> 

> +	if (mem->state != MEM_OFFLINE)
> +		return -EBUSY;

We do have the helper "is_memblock_offlined()", although it is only used in one place now.
So, I would rather use it here as well.

> +
> +	ret = lock_device_hotplug_sysfs();
> +	if (ret)
> +		return ret;
> +
> +	if (device_remove_file_self(dev, attr)) {
> +		__remove_memory(pfn_to_nid(start_pfn), PFN_PHYS(start_pfn),
> +				MIN_MEMORY_BLOCK_SIZE * sections_per_block);

Sorry, I am not into sysfs inners, but I thought that:
device_del::device_remove_attrs::device_remove_groups::sysfs_remove_groups
would be enough to remove the dev attributes.
I guess in this case that is not enough, could you explain why?


[1] https://patchwork.kernel.org/patch/10775339/
-- 
Oscar Salvador
SUSE L3

