Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F4065C46460
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 20:27:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7B172075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 20:27:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7B172075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54D596B026A; Wed,  5 Jun 2019 16:27:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FD906B026B; Wed,  5 Jun 2019 16:27:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C51A6B026C; Wed,  5 Jun 2019 16:27:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8F96B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 16:27:23 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g14so26637qta.12
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 13:27:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=wGxHiQlWFn1uiPqF46GhGASLxDFDSqAuue1nQQO+VCs=;
        b=rKGY/WzM3ApInfSGrk8mSlp4Qfg7zYlHJnt1LErGI31x6YkNV+ALC5DjwA/6G+Mwmj
         29eIWJc3yXiBDF6e+seNn4qk9e9NLXS0dy7UqGGPLpvQbhw7xtrq/uHFSWvGTYzbfCpf
         EbXN74mlz5QeVtHcc/nLClcaSlYoNr+RdGwjhD9BLxcKer0buFuxEbKn9ZicFvNVsD5F
         ntyleRX58i309me0WrxSH3ztG9t7tEtOYjSsfGb9bXLV0Gz9MWiIeLv6rODUAiPG2jc9
         pOmAguya9cocIBL4yTkTxiAviZcL2oiapB0cTNu2CV/+nI9KAEHj6kWEaGCNgBPiskjy
         Gnjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWltOVigPaXOZDLvZ4S/BRs1KdsXw8UD0sv65e3uB1O/OaUbBop
	C9OChUTwQujRFqn0O2pNpOqloYbYms+jSPZHRYPIoX79TGcrEXQmy6sRZoLTiQRtvp+bPtBydwH
	Sky1PwOjasCzAyaZxtDK48t8ueGFq1xTMhbXAfn+gDnB4M5OTplFhCw/a1WaRI25GCA==
X-Received: by 2002:ac8:877:: with SMTP id x52mr36682691qth.328.1559766442850;
        Wed, 05 Jun 2019 13:27:22 -0700 (PDT)
X-Received: by 2002:ac8:877:: with SMTP id x52mr36682643qth.328.1559766442156;
        Wed, 05 Jun 2019 13:27:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559766442; cv=none;
        d=google.com; s=arc-20160816;
        b=Px3if55GBjIr0TJeSfQoJFYfl77WJ2JJPJ4lMEKdtYxoC33rMAi8eMIXbt4DV1wNJz
         teokDA8Oj8RrYUQ5fBRG7z4HqZ9dM7dffmoNbPAFRwIw6nrFYbvbtE/RslfSMhTcvuFt
         HX4vTy94aYSZB2AWSbLVi3BKZDbB8zy9V9cWn+AuAAHGUKoDqHYj+sxvk46FlOronPSs
         NfimyZ9utluXlmu6EScm16HIcEsdqR9Y7/KO7Kelz1k3BColyB/aM59l8zobYQEr6mN+
         0T6msCxjl9up3Fwk8N81+9ESiyWpozvO8Xby/7PgW/M0xHBMXjU7keaKJxWbF/S3XDlG
         AExA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=wGxHiQlWFn1uiPqF46GhGASLxDFDSqAuue1nQQO+VCs=;
        b=gTh5LBjRcdL2mIxIzKWR75QCLI/H89VXrQxbQKxXsh221advE7OXgk8o+0c3Br2dQ1
         hMIallRAJB2lPDSCObFueNKGRJwIFwMwRFVuLexyTWjTFTS3lih7XKiIFUNailb11Y4l
         YWNW4Qiw2O8dJC4svzojjxBH4xWZROM6pNo93ZDGKlkUqsLMvvCgPYCX7zFCMqVheDeX
         TqoNQvzTL2F/OXNDI/0y1jiYlbaYqbWmJ1NETlu8bwAN7acGspk1Wsz5hooxZuRhFtW/
         NBIdA4LIqwCDpHL4Q4uRpyUMjDOiyTEkad58c2ObXl+GVB8WBjkufYLCv+aXf0u1UOBA
         tIIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z10sor11213549qtq.67.2019.06.05.13.27.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 13:27:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyNZwCNllCffk9CW8iJVZnNw6kyLj1Wao5YfIYT6vXREYUpwAyvBsDlsGb5oilKvNDw7Zk3hw==
X-Received: by 2002:aed:254c:: with SMTP id w12mr37738167qtc.127.1559766441824;
        Wed, 05 Jun 2019 13:27:21 -0700 (PDT)
Received: from redhat.com (pool-100-0-197-103.bstnma.fios.verizon.net. [100.0.197.103])
        by smtp.gmail.com with ESMTPSA id z20sm14611825qtz.34.2019.06.05.13.27.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 05 Jun 2019 13:27:20 -0700 (PDT)
Date: Wed, 5 Jun 2019 16:27:18 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, James.Bottomley@hansenpartnership.com,
	hch@infradead.org, davem@davemloft.net, jglisse@redhat.com,
	linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org, christophe.de.dinechin@gmail.com,
	jrdr.linux@gmail.com
Subject: Re: [PATCH net-next 0/6] vhost: accelerate metadata access
Message-ID: <20190605162631-mutt-send-email-mst@kernel.org>
References: <20190524081218.2502-1-jasowang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524081218.2502-1-jasowang@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 04:12:12AM -0400, Jason Wang wrote:
> Hi:
> 
> This series tries to access virtqueue metadata through kernel virtual
> address instead of copy_user() friends since they had too much
> overheads like checks, spec barriers or even hardware feature
> toggling like SMAP. This is done through setup kernel address through
> direct mapping and co-opreate VM management with MMU notifiers.
> 
> Test shows about 23% improvement on TX PPS. TCP_STREAM doesn't see
> obvious improvement.
> 
> Thanks


Thanks this is queued for next.

Did you want to rebase and repost packed ring support on top?
IIUC it's on par with split ring with these patches.


> Changes from RFC V3:
> - rebase to net-next
> - Tweak on the comments
> Changes from RFC V2:
> - switch to use direct mapping instead of vmap()
> - switch to use spinlock + RCU to synchronize MMU notifier and vhost
>   data/control path
> - set dirty pages in the invalidation callbacks
> - always use copy_to/from_users() friends for the archs that may need
>   flush_dcache_pages()
> - various minor fixes
> Changes from V4:
> - use invalidate_range() instead of invalidate_range_start()
> - track dirty pages
> Changes from V3:
> - don't try to use vmap for file backed pages
> - rebase to master
> Changes from V2:
> - fix buggy range overlapping check
> - tear down MMU notifier during vhost ioctl to make sure
>   invalidation request can read metadata userspace address and vq size
>   without holding vq mutex.
> Changes from V1:
> - instead of pinning pages, use MMU notifier to invalidate vmaps
>   and remap duing metadata prefetch
> - fix build warning on MIPS
> 
> Jason Wang (6):
>   vhost: generalize adding used elem
>   vhost: fine grain userspace memory accessors
>   vhost: rename vq_iotlb_prefetch() to vq_meta_prefetch()
>   vhost: introduce helpers to get the size of metadata area
>   vhost: factor out setting vring addr and num
>   vhost: access vq metadata through kernel virtual address
> 
>  drivers/vhost/net.c   |   4 +-
>  drivers/vhost/vhost.c | 850 ++++++++++++++++++++++++++++++++++++------
>  drivers/vhost/vhost.h |  38 +-
>  3 files changed, 766 insertions(+), 126 deletions(-)
> 
> -- 
> 2.18.1

