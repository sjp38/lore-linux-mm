Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0EC5C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 16:08:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54EC72082F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 16:08:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="QUHV/hav"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54EC72082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6C0D8E0048; Mon,  4 Feb 2019 11:08:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F2C98E001C; Mon,  4 Feb 2019 11:08:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8952B8E0048; Mon,  4 Feb 2019 11:08:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD208E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 11:08:04 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id i6so384189qtp.9
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 08:08:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=Li4m9VgzDn107uj2skKg4pEfVvnsw/uPImCizgtRdaU=;
        b=paZK7EFbZgyFmIkOYcMd5vAxzQtFZzilwI5rOsrZWimBCQTpA1SypMc/yVrn4BocPi
         K6B9f4FjfOdeO+Jr6yhttcDNESHvqsr4K485gImNMCVVokJZJM4/pAnqNXBw4PtkdhWk
         uFc/BTcRBjSrzhcXBhA0vw/Vm4pO89G4XWYi1Hv8g6r9gEA6in9DsbjyjqC81M5pASS2
         A9GWiDuNdjp/YrE1p+SgCqTz5hTcNcH/NuaSaY7+Ka0RbVrt8toWELxNkdgtKdtVv95b
         cbZpCoIchW84HtEYPN8rUufFGzrHHOZ7xMhQzxecP8FbaFAyviikPl49477vTgpyaF59
         UaQw==
X-Gm-Message-State: AHQUAuaFEuYYfOfxEC2NcuZyDsCNU2xqVLLxRlvpTK0Yo1mgssTQeZia
	Ws/wZZH5RnrezgOfRpnLlWjCnTOfzi2s3sSiNlh54d2A5eeLGZwRLNlSWXCEAl+BjEDBXd9bJ1/
	r4WCwv7CX6J7LMBfn5tOGduwlftJqMWx5RyGfbgz6eEiISAkxUHF8H7j5D/GxjSU=
X-Received: by 2002:a0c:9471:: with SMTP id i46mr106878qvi.120.1549296484047;
        Mon, 04 Feb 2019 08:08:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYAIgB27++8iDVcDv2mreZoP5TrzZn9inecmrFKtc4TJNwbO+Lo+Bd9Kog83ZDkHpv7w3nj
X-Received: by 2002:a0c:9471:: with SMTP id i46mr106838qvi.120.1549296483403;
        Mon, 04 Feb 2019 08:08:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549296483; cv=none;
        d=google.com; s=arc-20160816;
        b=MXMghauHCIFoOUszgmwpIZXL0cO5xF+gGVyqrHC3fJ8ng+ggUMeCVXqOSVmtE+4ca/
         D4qN4LndTJ5dqYSOjT/p4IRKuEfBDFTqBbm2Z3ewPguXjcuhSFMmVDuJwpnnGKrs6deO
         HFbcYq3ACiB+FG91wMaReEevKkSkKnusdB5KLlDdIRAf0+Ipets8Gg3d5ACWqvNka8ao
         o7F5RfRozBOS5zhhl3KxMM031Rt/n8FzQx6TF94vRMsklIEEZtIaovYaoZfnZO54LB68
         ggbgf/sTqIg1RjAhW6/OVQ6GyS4TOqXEhGl73Ddrsikfq9nUa0/vEx+ngVaUWP1d+GyL
         5EYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=Li4m9VgzDn107uj2skKg4pEfVvnsw/uPImCizgtRdaU=;
        b=mtPVfjWo5jyfeVNRiXiU+/BgEgdSGEPof35pIYSu6JGNdw6O45WkCxccFUhZln55Sy
         E2TAafGPImkl6IEoAQQ2LZhvP85mQ/VHwj9RIx3GBHb+1F2rsorJFJATs+qT1RkQFvfO
         8cKuIMOyrW9Z51UQCILSsVdeGSAO4lgM0w2IGiYGsEJUbJ0rNgH3fL+Z7WTe5gLGLErv
         Scvx2Fs8wERnnSYZRy6De/McDVo4q1NF3Bdm5TPacxflnwwG7U/UJHnMWcS/xt6AxF3O
         8YK1qJdcVc3MiALAUybggRETHBM98sEVXula5dpngn4Yljg5+CtEiMLg89hzCEL6FAro
         8j7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b="QUHV/hav";
       spf=pass (google.com: domain of 01000168b94439c0-28d5e096-718d-4e39-a7af-20d0a6d7b768-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=01000168b94439c0-28d5e096-718d-4e39-a7af-20d0a6d7b768-000000@amazonses.com
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id g89si5567310qtd.118.2019.02.04.08.08.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Feb 2019 08:08:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168b94439c0-28d5e096-718d-4e39-a7af-20d0a6d7b768-000000@amazonses.com designates 54.240.9.54 as permitted sender) client-ip=54.240.9.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b="QUHV/hav";
       spf=pass (google.com: domain of 01000168b94439c0-28d5e096-718d-4e39-a7af-20d0a6d7b768-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=01000168b94439c0-28d5e096-718d-4e39-a7af-20d0a6d7b768-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549296482;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=Li4m9VgzDn107uj2skKg4pEfVvnsw/uPImCizgtRdaU=;
	b=QUHV/hav0zNxHS+Wl87A0BoUBsD74FYkkpUunFx1l6GFEgByPtSLcygI9/Pk2syi
	C6bDLjL1Pdfq52boznJ/KtH8hLI32bTAvzHqB85YGHmpczLAcFacjAUZoDP3w0btUvN
	y/IW6A2TwMWHYVnMkaimoIdQsZdq3gV6plhPWU+k=
Date: Mon, 4 Feb 2019 16:08:02 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: john.hubbard@gmail.com
cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>, 
    Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, 
    Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
In-Reply-To: <20190204052135.25784-1-jhubbard@nvidia.com>
Message-ID: <01000168b94439c0-28d5e096-718d-4e39-a7af-20d0a6d7b768-000000@email.amazonses.com>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.04-54.240.9.54
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 3 Feb 2019, john.hubbard@gmail.com wrote:

> Some kernel components (file systems, device drivers) need to access
> memory that is specified via process virtual address. For a long time, the
> API to achieve that was get_user_pages ("GUP") and its variations. However,
> GUP has critical limitations that have been overlooked; in particular, GUP
> does not interact correctly with filesystems in all situations. That means
> that file-backed memory + GUP is a recipe for potential problems, some of
> which have already occurred in the field.

It may be worth noting a couple of times in this text that this was
designed for anonymous memory and that such use is/was ok. We are talking
about a use case here using mmapped access with a regular filesystem that
was not initially intended. The mmapping of from the hugepages filesystem
is special in that it is not a device that is actually writing things
back.

Any use with a filesystem that actually writes data back to a medium
is something that is broken.


