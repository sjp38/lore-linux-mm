Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23AEBC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:13:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA6D82075B
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:12:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eaq0BTRP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA6D82075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 857D16B027E; Tue, 28 May 2019 13:12:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E0D46B027F; Tue, 28 May 2019 13:12:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A8FC6B0281; Tue, 28 May 2019 13:12:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 039BB6B027E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 13:12:59 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id m4so3893806lji.5
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:12:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=7II5+XRnVobtVPgQVRQrDR8x4e5To08TyrztMHGvqag=;
        b=sbrUev2Gvvqe59VE/rOCdjnphJXeakSwU+ovldC77ts19HnTfe41MdLSFtcoqasift
         LbRJywYz0330iMvktoFEXKdsgdGf0sSWj7UD+W7hawHM9i7/ak5tXNvppqu7mGglipoL
         44CuF0Cs9XXLm4PuMMrzm3DwZdnarbgr6AoZyFW7cHgQ2negU3nBdi2BSbkPAhYdNrts
         IWv/iXN10A+zhVhn+beBjZKtm2CNXpSn5JTXSd1GbnXit2FuTYrm/t2HywcSOtBBewxI
         yztw0ZmI8XtWmDRePx4vavxtHGcxPAXNDhu/VjQV9NEJ3PoEPygJo3ym128P5Xq5pxRt
         dRNw==
X-Gm-Message-State: APjAAAXibT5oeUmb6cb4jPFFr0A5YD6mGf4UaiLm8gc1RZXxCRwS7+HK
	w36FA8j+1YKYozvWApLKQGuDnXc7EM9Zv4PtPyRQyF6uXk4KsScbpBAgOvPt+WBghIhMBhD+D/j
	UQGGMvOGxO59TP9xevVqKHDrD91+fqvq5FDrM3onbuIvxWpryIPOWyTVXrqtxAagtoQ==
X-Received: by 2002:a05:6512:64:: with SMTP id i4mr17594156lfo.32.1559063578468;
        Tue, 28 May 2019 10:12:58 -0700 (PDT)
X-Received: by 2002:a05:6512:64:: with SMTP id i4mr17594131lfo.32.1559063577727;
        Tue, 28 May 2019 10:12:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559063577; cv=none;
        d=google.com; s=arc-20160816;
        b=C7deQ2CgkSzIuaBb4VMnu9d6+tS5zMB1+dnDD6q1Z4D8exqdWb8NSjQgnfXZVeQN6j
         XWF9vYp9qXXjHYsCsIdUfhisRJcNcdxQukThJmLeXesx3diqhxTyG7JiM6+nNCI1HCpL
         a0Et+4AwNQYz/5pOiUHB4K8Ak55/IX+dm8l5Yq3LL3G5Fv2JIbOHvB1vtJR31jMKF+ar
         pBTqNY2FqftXgnCLtUsSpFaNTGbmgDqxsu31vV+IDLznBP2rDPIiOAiuLvN4y6EpWnPk
         OMJJ2vofBunyTq1DQNSWFmsyanEEdsMUwLVp77gHU/AS/rlPlgbrJl/cKKnGIr9FFaCs
         GVtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=7II5+XRnVobtVPgQVRQrDR8x4e5To08TyrztMHGvqag=;
        b=0AuXslwPIUil4Zjrp61kRGaQg34QJN45rvIzPLHC9Ogt7PBRkx/p9p4PP4upPUZEjS
         ZOlBNRUIcaASwCmBNu6lNAaEAKaq2lASvcDlEuI8qSFhCo4jV3L1986JiXsB4BnXw7vc
         nHoCDrMePdcY9wVFeK8ouYboXTQ5a5UahCWlMFk26Nnlkimz+Ey+pnF1wjhwwRO0gNIV
         TVTgZRiWCod5wEGoYOaGDk8ic5crG13moB9Gqlry988b8z4roj6Sf+fnYd7iz9SmU9OM
         jrFDu0RK7fI1hAupGQ1VEmGrpFlkG21AA5reKXJL+iR6F3Z3r2HpdbBHLULlrLL1LpPA
         xbqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eaq0BTRP;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i12sor1407526lfo.73.2019.05.28.10.12.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 10:12:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eaq0BTRP;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=7II5+XRnVobtVPgQVRQrDR8x4e5To08TyrztMHGvqag=;
        b=eaq0BTRPkhNafZhWSSYSrscltuZlK8p6kHWOeCVXycDQv7t3RspcGhqc4CbVFRfJ0/
         o7HJXatIFeoKZxyCMT287FoSfvrUs0U0xqqF+ZyaTxsF6AXOvHhx+mEnvBMiZVkkC7ec
         QCS0S+APb1j6fW2ryNi4o7g80ajjVeRBHQNbzfaBo7pN07pH1YZkz60t0gSOOA3Sa77n
         IUDDmczlKJ9hmuAndnQn4+Y/SUZKWO+OMmA80g+gjOLOd+UpCkLuevIe+dS8TuJtPJey
         2PC562PZ6yYaNgc3BidpuZdLxw+bNgr4tYYphKwEZ3XqIzT7w38tkPatdRI9FkWb/PTS
         N+nw==
X-Google-Smtp-Source: APXvYqweo1MPDUPsmU7agUat02Negiwx5X1FenEPDIVNxQGPC9Z7TsrTpK50AruQozndnwRD+b61rA==
X-Received: by 2002:ac2:4908:: with SMTP id n8mr3692243lfi.10.1559063577452;
        Tue, 28 May 2019 10:12:57 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id x14sm2989317lfe.83.2019.05.28.10.12.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 10:12:56 -0700 (PDT)
Date: Tue, 28 May 2019 20:12:54 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>, cgroups@vger.kernel.org,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 4/7] mm: unify SLAB and SLUB page accounting
Message-ID: <20190528171254.ymnytie2uc4hwd4v@esperanza>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521200735.2603003-5-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:07:32PM -0700, Roman Gushchin wrote:
> Currently the page accounting code is duplicated in SLAB and SLUB
> internals. Let's move it into new (un)charge_slab_page helpers
> in the slab_common.c file. These helpers will be responsible
> for statistics (global and memcg-aware) and memcg charging.
> So they are replacing direct memcg_(un)charge_slab() calls.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> Acked-by: Christoph Lameter <cl@linux.com>

Makes sense even without the rest of the series,

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

