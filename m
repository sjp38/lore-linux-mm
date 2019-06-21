Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78712C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:42:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 173402089E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:42:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RDDEklul"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 173402089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E0266B0003; Fri, 21 Jun 2019 19:42:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7692C8E0002; Fri, 21 Jun 2019 19:42:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60ACF8E0001; Fri, 21 Jun 2019 19:42:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0526B0003
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 19:42:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k2so4963827pga.12
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:42:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TaIqbWk/qURrzaiG5PJ5vsRuFC8iZRx5Z1dYzRck4T0=;
        b=GULNSdTUUfxlMArTGYIv/QEm6z9B6tZkTM29fA9/q65zRssT64+J4lXW5QJdLPvaID
         2wZ3pIOAiDRB6nRApNCavB0D+jQbq21rB4QRbnNrtMrkDm4WtbtiW0qmpKrEUSH4woYQ
         zJfAsQlIxdz0TGkDf97Hntm40/pJ8zNcrkmn3c2hNM9Ltgq+TMVpMwYMW9hhmzX/Wm12
         1MS+mZwoEzduTKoUj/ZKCtWOVE3c7tg36ZDG51Ah4LrlpnfDNcqnqwFcN50jaFSEMdhB
         K3bRuvPAxBS9Cx5zUj5z/szCtFNeL02BPcfJsj1Cu9JcZpuC9YQmUkY8iEb/c32tLgWi
         XfUg==
X-Gm-Message-State: APjAAAXwhvuWW84LUHgYfe7Xv8SIoEqvpcAzy9WAJ7P99pV9JAEY5hM3
	XkjSvp3x4/X69Upc1MxmWBPt4tCs1LExvlOrkoaTmpjUVScSQlAqT6OGGSqu0bpo2FFcXivwDiU
	neRW4FUkSWXWuykAhSIbjVmWFu0htR5n43qbP2kd7WPZgTF9wWH+oXHhuqEtax05eww==
X-Received: by 2002:a63:5152:: with SMTP id r18mr20077141pgl.94.1561160569637;
        Fri, 21 Jun 2019 16:42:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqtu4WMldOvePJ3G36Xb62LTIlbAGEgJnTlSyncv46M6bHVOUS6GdC8FAiYBEK2OxzEgUZ
X-Received: by 2002:a63:5152:: with SMTP id r18mr20077079pgl.94.1561160568614;
        Fri, 21 Jun 2019 16:42:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561160568; cv=none;
        d=google.com; s=arc-20160816;
        b=ejL4/2jXZXwmNC0FKiI9d3yKTwfDrqEG/cGKnGEUGdMMRIHkB1Fh1yVWKPYTM3a/xE
         mGIqoNY0PapU2LZX/sZ63U1oW6FwQRjH8rLWpmzCPi2X92gRybqKS6mC1ARGnuAzKBkp
         Aw4phVmYCBLpG5eoWTx9lPWMQUPwCeEEGvfeh6b3LZIH8ALh+gz02AigTylXnWOy2Nvp
         AF8SW+MEF21MGZXT0P5FxwDcdvdGc6aOn75keH4sZ8uH82ekCuOnQWtIYiYpHzkmydMr
         4oQ7Vs93OrbZ7pKOsUOFNK3RkSJfs2iPMzPIpcPAEJX3nErayY2LvTXAk85017LFhkMt
         rbGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TaIqbWk/qURrzaiG5PJ5vsRuFC8iZRx5Z1dYzRck4T0=;
        b=tCefg7Lggh47SoVCpF6ZLB0Bk3uOR7ANv75IIHWZ8Zw1yPfTO7c0ABd4+rUl9loPfF
         Va2TQq3CanhRNtrq+hvG8K887uFic3EeNjuCRcFy3fV/g71q1Zst+bWSk81ujn6FNJSN
         kSU5UNSzM1tKQ7ZDuk+pNu8Y4euU/8ZGP9Ydy+vks4wUuqsdjdyvObHboFbzFw507bmx
         GV/UGMdTB1BRmJ7emqXkTIb0uQo6Aj8yywY+XsHznPLvYCT+6mL1v0lde/KMQ1kfQ1QI
         XICdIGWH3tf6ksVrGwk6k2ETzcrkp/1sS58p9DYOhA1fA/8OQfjrvQtaf3bnrKtPn8Xv
         B3jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RDDEklul;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h8si3991754pjs.13.2019.06.21.16.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 16:42:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RDDEklul;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CC20B2084E;
	Fri, 21 Jun 2019 23:42:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561160568;
	bh=9jNNQ6ZuBBOjZIW3HIow9t4gY+OUpSdjtQl5zrDEMdQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=RDDEklul7g0TwzW9+rYABCiLxD3N9O7GjpeOksdPT5+/ufp4LUGpriR31HgIwLS4N
	 su+rzFDliqa/VpGbuq7WC+iq0nUGUObMkXCICTQFtPxehIJZ4EugjMAlfNTPpNEqd2
	 UO3XDcH6k2EANV4YmvD/OKPZrb5GXc3G08Mo32mA=
Date: Fri, 21 Jun 2019 16:42:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@redhat.com>
Cc: Qian Cai <cai@lca.pw>, linux-kernel@vger.kernel.org, Dan Williams
 <dan.j.williams@intel.com>, linuxppc-dev@lists.ozlabs.org,
 linux-acpi@vger.kernel.org, linux-mm@kvack.org, Andrew Banman
 <andrew.banman@hpe.com>, Anshuman Khandual <anshuman.khandual@arm.com>,
 Arun KS <arunks@codeaurora.org>, Baoquan He <bhe@redhat.com>, Benjamin
 Herrenschmidt <benh@kernel.crashing.org>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Juergen
 Gross <jgross@suse.com>, Keith Busch <keith.busch@intel.com>, Len Brown
 <lenb@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Michael
 Ellerman <mpe@ellerman.id.au>, Michael Neuling <mikey@neuling.org>, Michal
 Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>, Oscar Salvador
 <osalvador@suse.com>, Oscar Salvador <osalvador@suse.de>, Paul Mackerras
 <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Pavel
 Tatashin <pasha.tatashin@soleen.com>, Pavel Tatashin
 <pavel.tatashin@microsoft.com>, "Rafael J. Wysocki" <rafael@kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, Rashmica Gupta
 <rashmica.g@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Thomas
 Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Wei Yang
 <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3 0/6] mm: Further memory block device cleanups
Message-Id: <20190621164246.9a2354a571da41950bb74562@linux-foundation.org>
In-Reply-To: <1c2edc22-afd7-2211-c4c7-40e54e5007e8@redhat.com>
References: <20190620183139.4352-1-david@redhat.com>
	<1561130120.5154.47.camel@lca.pw>
	<1c2edc22-afd7-2211-c4c7-40e54e5007e8@redhat.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jun 2019 20:24:59 +0200 David Hildenbrand <david@redhat.com> wrote:

> @Qian Cai, unfortunately I can't reproduce.
> 
> If you get the chance, it would be great if you could retry with
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 972c5336bebf..742f99ddd148 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -868,6 +868,9 @@ int walk_memory_blocks(unsigned long start, unsigned
> long size,
>         unsigned long block_id;
>         int ret = 0;
> 
> +       if (!size)
> +               return;
> +
>         for (block_id = start_block_id; block_id <= end_block_id;
> block_id++) {
>                 mem = find_memory_block_by_id(block_id);
>                 if (!mem)
> 
> 
> 
> If both, start and size are 0, we would get a veeeery long loop. This
> would mean that we have an online node that does not span any pages at
> all (pgdat->node_start_pfn = 0, start_pfn + pgdat->node_spanned_pages = 0).

I think I'll make that a `return 0' and I won't drop patches 4-6 for
now, as we appear to have this fixed.



From: David Hildenbrand <david@redhat.com>
Subject: drivers-base-memoryc-get-rid-of-find_memory_block_hinted-v3-fix

handle zero-length walks

Link: http://lkml.kernel.org/r/1c2edc22-afd7-2211-c4c7-40e54e5007e8@redhat.com
Reported-by: Qian Cai <cai@lca.pw>
Tested-by: Qian Cai <cai@lca.pw>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/base/memory.c |    3 +++
 1 file changed, 3 insertions(+)

--- a/drivers/base/memory.c~drivers-base-memoryc-get-rid-of-find_memory_block_hinted-v3-fix
+++ a/drivers/base/memory.c
@@ -866,6 +866,9 @@ int walk_memory_blocks(unsigned long sta
 	unsigned long block_id;
 	int ret = 0;
 
+	if (!size)
+		return 0;
+
 	for (block_id = start_block_id; block_id <= end_block_id; block_id++) {
 		mem = find_memory_block_by_id(block_id);
 		if (!mem)


