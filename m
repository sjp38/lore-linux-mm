Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB69BC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:15:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 665C220C01
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:15:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="1mu1WFjK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 665C220C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 007876B0003; Tue,  7 May 2019 20:15:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED2956B0006; Tue,  7 May 2019 20:15:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D73BF6B0008; Tue,  7 May 2019 20:15:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA6836B0003
	for <linux-mm@kvack.org>; Tue,  7 May 2019 20:15:30 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id u135so6545531oia.2
        for <linux-mm@kvack.org>; Tue, 07 May 2019 17:15:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=UhaIzukcu6eNmGwjEhDO3TIFvcLokXuz7xzLGx18Tbw=;
        b=uRuO99yedyCKUj2F+1o8sCU1CqgSJBPDZ32NvImCXa25HQTREZNwiCoWxVd/tftYEi
         6/kyQTaEwU6I6QKSWBHjTKoNpMGK/w+/+eAfqxlGVOGBJKIEer1jAQSQnLoVanXtOiv9
         nvWumEJFDn8UZC4crdbhCF23WOUNjCLzNv4WpChfc+9w6VoU8RuoDsKqQzMycUY7OaGm
         HO129oNQP6YnkzIPRIS/PPPVbx5imrkNbQI72sj4XFkq9zJVEhQwwCUmHb41dQeVcWN+
         GTlyDEdQXPT20AlsENLbPh8B84eYMZIdJYUXHLzpDgl3vJXwtmzx/BNWfvjTkEInY0Ib
         Nbwg==
X-Gm-Message-State: APjAAAVE1GsYGUZBlcGCQddxUBiCSkNV6S/oHil6k8Fgm1kiYYRXtFUN
	l53XlajbEwidoJkNMBgdiwp71rgxkL/gbDTTmR+MAZ+k3sTG8qKZoyYQGvisn7LoMJpiV82z+re
	IGQCyu5+dQJyay5oL/1szTCSv37MEy/1jG7z5j5VvaBTQFnyu8X4Ls8bBEvUp7Z3afA==
X-Received: by 2002:a54:488a:: with SMTP id r10mr82800oic.26.1557274530258;
        Tue, 07 May 2019 17:15:30 -0700 (PDT)
X-Received: by 2002:a54:488a:: with SMTP id r10mr82776oic.26.1557274529608;
        Tue, 07 May 2019 17:15:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557274529; cv=none;
        d=google.com; s=arc-20160816;
        b=bXJQsXiIWasEoIRu0320lmyxQ3joHhx0TrvBAAdypBWmdxKNFwZ3qgpQScLs1HDMDH
         3NBN5mNgeyLeBWlyavr18zPUAjapl7aEi5OudcclmKWYdFRoYjH4da4J23w7TVeJKJCy
         6xng5Uox1JrnXIozAasU2IaCcvDC6AcJ5MXSC0xM6SnC0nll+Efif1w+8DiyFNgI0hlX
         sHKW3hIaDzDYBOeyMqKwpx/oXLbSrjerE4axrKqDcCbAsOJtuG8Oqw9wlaiYWFcTjxjP
         wgfct3jYR5/Ukb6M52NoZkvRBROz1rykVEotll2+TCh2p8sYXikttcajtl4JW8GOthiB
         8yUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UhaIzukcu6eNmGwjEhDO3TIFvcLokXuz7xzLGx18Tbw=;
        b=QSXmyL30t4hSLEOJYT9E+DRjvOWQDNSoXgT4EnAdqdmE8gpI3Hu7SAtqa1If/nyzKb
         x9AKjHJ88Z/vNGp2op0LO9pNjjilpLEPQHHEPw2jopSs4SFgAEW1iwpK2b/atPvFK6Qc
         jkQneaFxG8nqbXo6Z7Z6I2wfmTmnlA/ezQkEQhs4zttla2Y+nWoffz+GQIL9SW1ZFy9F
         FVf2yWS1Mev78ok6loWG+MnXAzu5nL3nYaG8u6IHhkGUihjC9SQASSS0bucqAuFetUQ9
         b3ikadg4IsoM6RT2CDPiEE5San2eIykVN3tIK+5jmIAKyx56FO8gY2zLrZJWe+50EMjY
         wNTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=1mu1WFjK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o23sor6957757otp.63.2019.05.07.17.15.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 17:15:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=1mu1WFjK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UhaIzukcu6eNmGwjEhDO3TIFvcLokXuz7xzLGx18Tbw=;
        b=1mu1WFjK0V8iMe1wMq6x6KzZRhtmQz1Se3V/vOtmmVL+ajookiHe5WaC/HRVqi1aOT
         pNOu0Kkq1JuDbFSEaVU0Q4YkN/2yshcr5Htq3wxT0t3oZMqjqfMg8Vq+soNUv9VYZmnz
         qi0ztt0Qg3G28TqdCTjWN1vnEVkOFntia6T7xZQSbhlue+TZ0cKMQElA/dVVyyHBtKYa
         +kuijAfBzxNmyY5C2URmhzlcqkDHeMIdKNYXQ5ZH8xBIjnqCcCZA64C8WvdBdR7YoQZS
         AJx4tTL7B5nNdsxXhvCIL0196DLuJDpCHwejztP7AEsIElbkHYHSNTQyFj+ksRiC53FU
         f1EQ==
X-Google-Smtp-Source: APXvYqzzxf6W9cnydO305g7fBJWgCOG4eg30Hdr9Euys8FINHS8ep2uY1uSq5jErxGYFDhvPRGJuaspiSElcCykByLo=
X-Received: by 2002:a9d:222c:: with SMTP id o41mr23840445ota.353.1557274528508;
 Tue, 07 May 2019 17:15:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-8-david@redhat.com>
In-Reply-To: <20190507183804.5512-8-david@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 17:15:17 -0700
Message-ID: <CAPcyv4h2PgzQZrD0UU=4Qz_yH2C_hiYQyqV9U7CCkjpmHZ5xjQ@mail.gmail.com>
Subject: Re: [PATCH v2 7/8] mm/memory_hotplug: Make unregister_memory_block_under_nodes()
 never fail
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, "David S. Miller" <davem@davemloft.net>, 
	Mark Brown <broonie@kernel.org>, Chris Wilson <chris@chris-wilson.co.uk>, 
	Oscar Salvador <osalvador@suse.de>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 11:39 AM David Hildenbrand <david@redhat.com> wrote:
>
> We really don't want anything during memory hotunplug to fail.
> We always pass a valid memory block device, that check can go. Avoid
> allocating memory and eventually failing. As we are always called under
> lock, we can use a static piece of memory. This avoids having to put
> the structure onto the stack, having to guess about the stack size
> of callers.
>
> Patch inspired by a patch from Oscar Salvador.
>
> In the future, there might be no need to iterate over nodes at all.
> mem->nid should tell us exactly what to remove. Memory block devices
> with mixed nodes (added during boot) should properly fenced off and never
> removed.
>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/node.c  | 18 +++++-------------
>  include/linux/node.h |  5 ++---
>  2 files changed, 7 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 04fdfa99b8bc..9be88fd05147 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -803,20 +803,14 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>
>  /*
>   * Unregister memory block device under all nodes that it spans.
> + * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).

Given this comment can bitrot relative to the implementation lets
instead add an explicit:

    lockdep_assert_held(&mem_sysfs_mutex);

With that you can add:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

