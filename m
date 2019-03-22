Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CC2EC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:29:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C708A218D3
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:29:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C708A218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E18846B0003; Fri, 22 Mar 2019 10:29:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC87C6B0006; Fri, 22 Mar 2019 10:29:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB6696B0007; Fri, 22 Mar 2019 10:29:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF586B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:29:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e55so1032785edd.6
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 07:29:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:mail-followup-to:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=aAbTSPfnapB5KkR5P3n4RJul4ValycjVVK/Wy7AHcC0=;
        b=Fw6QifYtY5HAXxSUOd3EJ6jysFJioEUkjTccSXT1VYhlUeOazEg7dstPkjzTa30f+d
         LtNHpPyUMq8oUJ2XRdF48RsIGhGdmQwPZ4xO33eCFD5M47YWwoJAuTRr59DzOr1MIlxA
         QPeykXWuASMYQmPjYQm5uZD6QG8gY8GR5fIeHs8e51u9cZgLZqh94dmVQg5fK1CHjm9n
         U9AXDES7kVhe4do6iJa8b5G6BmGMeoU4onmbVAcwlKDa4bjt1N2cG0oOnbq2ZBasZUH3
         IcuGeMZ6k2hz+kgHxYgPqgmUZvq7EbczQkGqx2b0ml8ZJfj/eN8jjTSLw3EBGrY8TOgK
         deUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
X-Gm-Message-State: APjAAAU+0DvTAqK2zW1W1XqUYrEeFlbQNkXqMtbpgFqBeQdNZnrj3Cfp
	GG56NmImxiinJixySompXErIvmjxxdU56jfSW4eGKkHnlu17yfqkZxsYM/Vafx2Ud51hUitisDV
	sRoenFKE/DusOCqKvIdH4A1/yBflqhuTMtQulyzCZdaWA4clXs6pcABwaf3mOn7shAg==
X-Received: by 2002:aa7:dd8a:: with SMTP id g10mr6589412edv.52.1553264956077;
        Fri, 22 Mar 2019 07:29:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUKiViDG2DerNyRF6WjPTuGf2pHtTpG0c9RHWs0cXTy5URQ9SgnwWhzL7hOF7dty8L6XBW
X-Received: by 2002:aa7:dd8a:: with SMTP id g10mr6589351edv.52.1553264954938;
        Fri, 22 Mar 2019 07:29:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553264954; cv=none;
        d=google.com; s=arc-20160816;
        b=FDPqTCEF6UEjSTQyVwrs/jiBOn9IRg5QsL0AYDoSermTWT1zUjsPJ3+I39vnJhpcSI
         L/UnvdlnAw+nl6I3rUavdXXIw0f41cXvTWhiqap2/bG7f5yeXJd4LeYfdRSZMdTFl7PT
         eK80qLYhB5GGabqhKr/GgT68BCvB9rP9qRZMD92RdhS/U6w+GBedbr0sNN8cpiQatpUl
         t3dbfBSElx/zOzq8qpjHsKasleDJjzZivphQTKzmmby5tcULjJHe4i1ao3tK+t4KfMW0
         PpnPL26/2Gxg2tleS9PPJpxRpMZQGZcwuwpuc5vkOcmzGB9JXdbDlh7vcidToLDUFqgN
         UidQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:reply-to:message-id:subject:cc:to:from:date;
        bh=aAbTSPfnapB5KkR5P3n4RJul4ValycjVVK/Wy7AHcC0=;
        b=cM5DESl+hesAXAUSUD9yX13wKo6iqkYYhuUL0/0Ol0g9Wd2fmstLfUrAAvRb6L1y3O
         74WCqkFkz5xs0/qs146/5xeRh1v6LIiTa1imjbRHOA7O2vGplxAGbrC3j5Z844MOwAfh
         oFymXcmzaQ55yekk4zw0HM/DCnvpC77O4699o+wBLo7FYZJzCDUCE/X6h2OsRUwBgzBH
         zOv9WInhh3b58i9yBjUjsGEDNQxvO8VjFItHx0/EI3vZWUEAyYpAmluZ6yDqyy0gTUre
         eT0YCPQ/2zHYZwbK1lnKQgMC1JEOKP1WU3bOXoAVvec/pr5RUgou3qKkWQOf0hPglHpZ
         R0Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s18si2468280eju.252.2019.03.22.07.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 07:29:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 434CCADBE;
	Fri, 22 Mar 2019 14:29:14 +0000 (UTC)
Received: by ds.suse.cz (Postfix, from userid 10065)
	id 7D8A7DA8A5; Fri, 22 Mar 2019 15:30:28 +0100 (CET)
Date: Fri, 22 Mar 2019 15:30:28 +0100
From: David Sterba <dsterba@suse.cz>
To: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: Petr Mladek <pmladek@suse.com>, linux-kernel@vger.kernel.org,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org,
	linux-um@lists.infradead.org, xen-devel@lists.xenproject.org,
	linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org,
	drbd-dev@lists.linbit.com, linux-block@vger.kernel.org,
	linux-mmc@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-btrfs@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-mm@kvack.org, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org
Subject: Re: [PATCH 1/2] treewide: Switch printk users from %pf and %pF to
 %ps and %pS, respectively
Message-ID: <20190322143028.GD28481@twin.jikos.cz>
Reply-To: dsterba@suse.cz
Mail-Followup-To: dsterba@suse.cz,
	Sakari Ailus <sakari.ailus@linux.intel.com>,
	Petr Mladek <pmladek@suse.com>, linux-kernel@vger.kernel.org,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org,
	linux-um@lists.infradead.org, xen-devel@lists.xenproject.org,
	linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org,
	drbd-dev@lists.linbit.com, linux-block@vger.kernel.org,
	linux-mmc@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-btrfs@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-mm@kvack.org, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
 <20190322132108.25501-2-sakari.ailus@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322132108.25501-2-sakari.ailus@linux.intel.com>
User-Agent: Mutt/1.5.23.1 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 03:21:07PM +0200, Sakari Ailus wrote:
> %pF and %pf are functionally equivalent to %pS and %ps conversion
> specifiers. The former are deprecated, therefore switch the current users
> to use the preferred variant.
> 
> The changes have been produced by the following command:
> 
> 	git grep -l '%p[fF]' | grep -v '^\(tools\|Documentation\)/' | \
> 	while read i; do perl -i -pe 's/%pf/%ps/g; s/%pF/%pS/g;' $i; done
> 
> And verifying the result.
> 
> Signed-off-by: Sakari Ailus <sakari.ailus@linux.intel.com>
> ---

For 

>  fs/btrfs/tests/free-space-tree-tests.c  |  4 ++--
>  include/trace/events/btrfs.h            |  2 +-

Acked-by: David Sterba <dsterba@suse.com>

