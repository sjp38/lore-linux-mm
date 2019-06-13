Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54768C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:30:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0B5D2173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:29:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PsKvLzul"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0B5D2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67EE78E0002; Thu, 13 Jun 2019 15:29:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62F488E0001; Thu, 13 Jun 2019 15:29:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D0418E0002; Thu, 13 Jun 2019 15:29:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 163FE8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:29:59 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y7so15156823pfy.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:29:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=D5VuumMmQckexCkx1gvf8MG4/teLQOkFAExHtMrV75E=;
        b=btyzaJB4b9kRni6dZHvsXcR11WVYtT/j/67CNVCUekB1GJAZFr8RmATEm5QzxahWVh
         1BH8cdvRU011Xp8D8PvOXzsWgnlXvlzZWbc33I5k54c74fNFBLatLe97yYjcEUOtaRvH
         V6yEnmtmyU/B/o29y6c4tvA2tN6XUrqnlvBbFJpL3D0KskYd3gYJw+zMtMhp0K1L3i6U
         OjP/gtczepuNgEbT5r2DRedRbXNmuU3tUVSMia8612J6eFt9CTjyenYaJICl6bughhc4
         koLWKoVrb9rnGS9eqfdvNMHE62Ipj1WaA1IrCFh2aJfs4N3GrFsk4hH14s55sDgtz9sl
         A/6A==
X-Gm-Message-State: APjAAAU7udUiSX4k5eBfCCnyo2NwgZwpiTkBI88nCWrJgek8XywOwQVM
	QdxRiRfI29to/Q39OfATJ1mJsjwZFdEBAwvkNjz8V0iSf+4GS7ZK+El88ftgT0gDQGfZZCiuo8a
	8lwVhbG2LNiGDTLJTjEYj3tHbsTosO5xZtGnL70CwplUD3uF/DbDwCxNZexhlRcL80g==
X-Received: by 2002:a17:902:b094:: with SMTP id p20mr24109285plr.337.1560454198753;
        Thu, 13 Jun 2019 12:29:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfbrQAfhGAjiqRM8lFxXPyUk2y7LQ96vFv9G94Ot1NxwkDAlIisjlYdgqp5jczi7ts9vZW
X-Received: by 2002:a17:902:b094:: with SMTP id p20mr24109254plr.337.1560454198082;
        Thu, 13 Jun 2019 12:29:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560454198; cv=none;
        d=google.com; s=arc-20160816;
        b=TSor9hHZj6asDvBCRVC6cnh29WDtTxZwKVLD6mTP6xTp28hO0w9RQhO1ptr4WkFHcR
         G2iangF1VxzYy/8S237L4wM33RyWG8rffLbDOTMj8XMVs4RXXv0sRGTCUKFmUY6EQkus
         /aryk6Ek/WoQlyvIgPsKyAG5nt/d52hdW7HHj/gAtcsiA6jAjU/1skAb1qXxyhMlL+Kn
         q5LpiAcW/sdVhsx6gSnkMT7joFvOa8ewm3RHzyvePQDs0PY/ypn9w1142STiQj7PUynQ
         PZrh76OYPbg2qtvqTh86LiQT/P1nkzEHBUdF5aoW6wpRcVpoGDF/WQlBTDhLB3KO4xex
         /qTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=D5VuumMmQckexCkx1gvf8MG4/teLQOkFAExHtMrV75E=;
        b=neSE1colaXxwpaWfO6JmkLhoUlZYvdTJ4g14AFIaoEN++lM8lg54z2kbsjRqPE0j2H
         2I8A8MAljHENtibyt9B3HGNvXWq9Vmr8UcJJ4kszwk4vJu7hr06g17KfgeWLSsOb6Jfw
         mr5KzxyTUd4FiZAHi9T5iFpsah64wo/0yiKArREdUMupzK+BXqkyNaeC9/Ejig3etXD6
         UmVBvP8lv/nIYjII74CjkC+st/Cr7gA78u5GtGrPw0wKUsIG0NupyPh6SKR5JtLomYAE
         ZhtvJkxtajVpeDA1k5bvzpYPDB5U8OZpZzgVk10d3BHJGGcgN06d/KiU/lNb+PynrX7d
         kKDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PsKvLzul;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x24si488500pgh.393.2019.06.13.12.29.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 12:29:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PsKvLzul;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 55DF62147A;
	Thu, 13 Jun 2019 19:29:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560454197;
	bh=3nq7RwSer/Bwj8wjlB+pF0Ss6fAkxhqxBxJF0LKmZok=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=PsKvLzul3M76GkVQT+iREuWkduH+sv/EbpqVqvWMxorQopPHVDOT2k5gkJNIiKZLo
	 Wt8JuIjy7KWL7G7WfDWj49p2z5kDCYd6eCd4e/tJkh8JYO8BuqeKnzN4SCFIjyzuSX
	 8pGOSssDk1JR7zA93vfBURmASTgo8/sfqPOhARXQ=
Date: Thu, 13 Jun 2019 12:29:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Joel Savitz <jsavitz@redhat.com>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
 Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V"
 <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Ram
 Pai <linuxram@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Huang
 Ying <ying.huang@intel.com>, Sandeep Patil <sspatil@android.com>, Rafael
 Aquini <aquini@redhat.com>, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v4] fs/proc: add VmTaskSize field to /proc/$$/status
Message-Id: <20190613122956.2fe1e200419c6497159044a0@linux-foundation.org>
In-Reply-To: <1560437690-13919-1-git-send-email-jsavitz@redhat.com>
References: <1560437690-13919-1-git-send-email-jsavitz@redhat.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jun 2019 10:54:50 -0400 Joel Savitz <jsavitz@redhat.com> wrote:

> The kernel provides no architecture-independent mechanism to get the
> size of the virtual address space of a task (userspace process) without
> brute-force calculation. This patch allows a user to easily retrieve
> this value via a new VmTaskSize entry in /proc/$$/status.

Why is access to ->task_size required?  Please fully describe the
use case.

> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -187,6 +187,7 @@ read the file /proc/PID/status:
>    VmLib:      1412 kB
>    VmPTE:        20 kb
>    VmSwap:        0 kB
> +  VmTaskSize:	137438953468 kB
>    HugetlbPages:          0 kB
>    CoreDumping:    0
>    THP_enabled:	  1
> @@ -263,6 +264,7 @@ Table 1-2: Contents of the status files (as of 4.19)
>   VmPTE                       size of page table entries
>   VmSwap                      amount of swap used by anonymous private data
>                               (shmem swap usage is not included)
> + VmTaskSize                  size of task (userspace process) vm space

This is rather vague.  Is it the total amount of physical memory?  The
sum of all vma sizes, populated or otherwise?  Something else? 


