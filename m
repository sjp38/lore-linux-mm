Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDCE7C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:45:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A65C0218C3
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:45:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lJJ0d87T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A65C0218C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AAD38E00EC; Wed,  6 Feb 2019 13:45:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35C3A8E00E8; Wed,  6 Feb 2019 13:45:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24B668E00EC; Wed,  6 Feb 2019 13:45:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA76A8E00E8
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:45:49 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id d18so5900208pfe.0
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:45:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rg0qhHSmzMn72DydxCUMoaDdKVyXmkj05Pc8uIwpjPA=;
        b=fPsIVvPR7zx5dhHTuAXU9X3Sk/qHz/xC2zFTu+74eLpsIqYnWEKjsnDuJZkDE5pl/f
         d19uyUXDUrdE7gqOCZGh4DqH7tmX4aGwwsLFirULmV4/f9aNeKJkIYHC7PyePAklXVT/
         PQDl54Tw5G6rowb4UX+TyFc+NNYPjW7kypNYoHpsp1uDPtCUjFS55NsjTWXzH/pP4Efo
         otw8qdSI1CJ6uE85NdOICclCp5Udr0BRAzobsYEL5PxdyDTE9XKRMZhLtsgBBmw9HTuu
         W9vE0zQAbQ97G4eFP2DzQqqpbBm4FN/e1woPqyJeOsGwi5FNQGWbSKRgXB0DYTe+9L06
         +XXQ==
X-Gm-Message-State: AHQUAuayXVL2wqbGV/DZ8dIGBk2VQHLabUsvXxfyU5Cvjy8gtgytIpCv
	L3Ydx89xWBhVhRX2H6bvc5GVS1D4dU0Xh0j96W4RSvq/5OufPjplS39UV1toAkWeyJOYaSvByZi
	4U6WYFEELFcmNP31+y9PcnljL6mbcpO03Kyj2zrpx62P8bN2pUI2rQf6+kHMS88c=
X-Received: by 2002:a62:442:: with SMTP id 63mr11670247pfe.156.1549478749551;
        Wed, 06 Feb 2019 10:45:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib1SD0s9693goTkGQj4xKMF9SV7xrAGRYhWz2TBz0EKWsnea83pc3tf/IrMGHLHnWy6VLK9
X-Received: by 2002:a62:442:: with SMTP id 63mr11670191pfe.156.1549478748651;
        Wed, 06 Feb 2019 10:45:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549478748; cv=none;
        d=google.com; s=arc-20160816;
        b=uQ0en8O3qd6rcP4J6dM7DqpBXWbJscByRTOClb543nMr9Ukz8vGclOLBskgItHM/Ak
         7Clpc4XOVtmFOSvyecxnG8Ky96UJ1SzTErNiSEpBtoWew1yslrQWXJtyA8FUi5PbNjBR
         93n94xA54Toci64tUmFkQpD+p8Cb5IKFzd+EbNuAiSQ3Rso7oonMPdr+RPGXBH0XA9s9
         qXG6SY8hdcswU9uhkr6aQbPqps7Xb7avCjfNQOjf1FOZBHiptwvi3V2o8EamMETuDfxN
         uTaNPSvEYp7z3sJGmXuqLSRVgJmaeWEwgKLNjWQ2j+iLgzTd9YcGH7LgUQ99W4S2HN56
         Ny0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rg0qhHSmzMn72DydxCUMoaDdKVyXmkj05Pc8uIwpjPA=;
        b=vmhGU0dY4vqm8tfUji0bSgZoXDorBYmH3vkuvcmWytW8qTp1yZkyF0/EdsXc8PuBsG
         gvwcaeumIktlW+EfXSIVKW5QOCjJ0BEmHWUIkmrnWvX7oJiQYFdtSq9IDAzZgXqc82/T
         DScbDJ1JQ9w9hOGSbQ/w56MiQnP1LORoWet0VprshKZR65m48OM1HQY0YVBQrqj1k8x8
         jX5pNpez/NFVWRDdTFNBHUcdXfmjOkIIXsB/FNnpgvmeYIbw20f3pSsUte2uDhj2gWg3
         E25pZD/CdFYQh6LbhKouPWfZbjTYsAGbbwMw0Fln8QPXHt+pIeNq6TCdwNpkNKRQylzO
         ROjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lJJ0d87T;
       spf=pass (google.com: domain of srs0=ghg7=qn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=gHg7=QN=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 18si6381399pgo.331.2019.02.06.10.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 10:45:48 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=ghg7=qn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lJJ0d87T;
       spf=pass (google.com: domain of srs0=ghg7=qn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=gHg7=QN=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (unknown [82.113.183.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7467420663;
	Wed,  6 Feb 2019 18:45:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549478748;
	bh=vbH4AwZlRuUyA5PbdaaE7WSWqBjlRx7Qid917Qq5lYY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=lJJ0d87TuH/5s/Z7r+2ODZcbHw+9fQNWFx3IqBSFOdIRR2HH19ozFp4slaVQ0r8Kl
	 X37tKh8TmFgMa/2NBMnmWSApoQ+9GqyVuG48Sueyoh6MGEcQn8RVDNDaWRPtcWNb9C
	 Pt24tafRsWAFbmPOA13qjHUXfbrT0nQdZzxKxz5g=
Date: Wed, 6 Feb 2019 19:45:44 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rafael@kernel.org,
	mhocko@kernel.org, akpm@linux-foundation.org
Subject: Re: [PATCH] mm/memory-hotplug: Add sysfs hot-remove trigger
Message-ID: <20190206184544.GA12326@kroah.com>
References: <29ed519902512319bcc62e071d52b712fa97e306.1549469965.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29ed519902512319bcc62e071d52b712fa97e306.1549469965.git.robin.murphy@arm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
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
> 
> Robin.
> 
> [1] https://lore.kernel.org/lkml/22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com/
> 
>  drivers/base/memory.c | 42 +++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 41 insertions(+), 1 deletion(-)

You have to add new Documentation/ABI entries for each new sysfs file
you add :(

