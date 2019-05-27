Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D24BCC46470
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 19:12:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73BE621721
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 19:12:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="H+MT+D+q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73BE621721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C850A6B027C; Mon, 27 May 2019 15:12:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5ACE6B027F; Mon, 27 May 2019 15:12:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B489C6B0283; Mon, 27 May 2019 15:12:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA316B027C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 15:12:51 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id a23so3991957uas.17
        for <linux-mm@kvack.org>; Mon, 27 May 2019 12:12:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DDviHOtsxusWnOlAhiLZnd4GLm6Sq0zvvnS+jtdVWoE=;
        b=QI70Ifpvuv/WlPiB7pCWX6/BYFKiMsxPM8i9iBsOylqfDgHXEA6PS1zooaDMGkwdDr
         7tydASA0B6GFIBfaqVg+OOVqsGryx/lWzC6nQO/WFw8w9XbdpX6bH29M3k1eBionSxpi
         cLs7tZfsGxKoZg1nsCEQXqTBHboHMjroFgLomxSFYChsjtjCVxHlg1dg1SXcQ0y3gizJ
         4VlWTjgkUjJ+6BtXEdalWLUDdefQmoKK6KWNFWcZue/RjnTwPkk2TPOdVh1Ywc4uroEK
         n+yaIuI3IXFkl3BMTftwjMcOynKqS8UoktHYACKuSzgL1qNherXTOqVEvEchwVTodevn
         IXDg==
X-Gm-Message-State: APjAAAX1S1cgZDrGS8u8EQU8zocqvqPuLa5w8qcUSoC3xXZsfQCWRsNW
	GxugtNzHdauYXMNw3YQlaupE2b0WuHajuXjfX7WQ/ohVzwTrGSUdMuMShmQUup8x98vzY4RHIHD
	tR9g/Fa9WYbslKwa7QE2dJSisc5KBTDIKmZCggsk6UrAzpGC2VKSmwRKvw//rZ035+A==
X-Received: by 2002:a1f:a54f:: with SMTP id o76mr21174435vke.86.1558984371229;
        Mon, 27 May 2019 12:12:51 -0700 (PDT)
X-Received: by 2002:a1f:a54f:: with SMTP id o76mr21174317vke.86.1558984370114;
        Mon, 27 May 2019 12:12:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558984370; cv=none;
        d=google.com; s=arc-20160816;
        b=VQyycCpFaEi6AvaMRg7IudViDcAYB+RjGvteIe696PEccspZUdQ+GN+K3SFOsCnhTK
         bWUnsiCFGUKrUAeZTGTau0y8gHTfziitAXIrn5qb/pDHbVYCQxR6mSBN4IVFk8jkBWCF
         W+updXtwoR3V0FvSveeLSfYmx4oJUVcggZLC8Qerv9pGUqunlsEWj4ZyBa4jEnMvefQo
         kL7jP4RN+aINbOaHoqJvCZLzgy5rPqfhlHloPticZi9E8HtJmzetyooc1F8Wy4d7vmtv
         tm7BeAgAGVjRNpvmW/xIh9Gsj9hJk6B0fTBTphIX0mjzaMkmIx3+wke9yNnKcGfzHzMs
         j81A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DDviHOtsxusWnOlAhiLZnd4GLm6Sq0zvvnS+jtdVWoE=;
        b=PTnKTnyLnJadBc4tQmD7veCsaX6lkTdTIEDJQsoSelSiuTiePHtiPlT0zjyFFaeENH
         8QVMCB/5J/h8uGu3CIW1vTdzk1YZWYVuTVfgIHZWdwJESlArvxoZjquIk3WmnPLg34B8
         qVIX8LJUzO+Lf9ARogAwHsAbn15cTJKxoWj+uFdDl74Orcrm2KC0It3I+YHu+bsF7VB5
         6OwNNhOjc0K7baD8TmhOfil2Ex0pl6dk/SUYDT/XIFKtfECZMIfc0kRSDG4JP/e3G8eA
         iRG246eyqHI2h2PLswda9q/9obbCIXiqht7sAT3mS4BbkmdPT2oI9YHtIDoPHeqk5xBR
         o7Vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=H+MT+D+q;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q11sor4497609vsh.42.2019.05.27.12.12.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 12:12:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=H+MT+D+q;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DDviHOtsxusWnOlAhiLZnd4GLm6Sq0zvvnS+jtdVWoE=;
        b=H+MT+D+qhOc67FUjiLtXFXQ+JoPD5S1DdC7CSc4dUolQU3JyIJasuwCyeRcrJ0PgNf
         bn8Chih4N853uCVFO25N5GX7p9RL+5D0yBI23Dj3DCO1rNJy1hSLJM5Pymyb1Y7u9fCj
         wuh78HiXJf7rrFoSgLBgwngyDm7eaovdd20ZaYVrQX6zm9XfqAjJG2AUO8Dl4fs08Cdk
         yAbgDtOcJYKveAP1EhrvJE/N8b1nhAIAs1qTQ625JOgpAYRB5cQ4wmxqfMtu71CJWoVY
         /2vs/OIWvzjVWfYHCgN2L1FahPam1FZBvcupwUncDJTjYqt1OfNHBp3EgxmEX94n9d7K
         RZHw==
X-Google-Smtp-Source: APXvYqz3S6V5VX0DS9Gw1Glb0NcMYV9JcZsL2/HpeHZOKpnuHyIw3v1JrcSgwxDKXpph1YUf5NB65w==
X-Received: by 2002:a05:6102:2008:: with SMTP id p8mr31279114vsr.73.1558984369444;
        Mon, 27 May 2019 12:12:49 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s78sm5202319vke.1.2019.05.27.12.12.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 May 2019 12:12:48 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hVL39-0003MZ-Q1; Mon, 27 May 2019 16:12:47 -0300
Date: Mon, 27 May 2019 16:12:47 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Airlie <airlied@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jerome Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	linux-mm@kvack.org, dri-devel <dri-devel@lists.freedesktop.org>
Subject: Re: RFC: Run a dedicated hmm.git for 5.3
Message-ID: <20190527191247.GA12540@ziepe.ca>
References: <20190523154149.GB12159@ziepe.ca>
 <20190523155207.GC5104@redhat.com>
 <20190523163429.GC12159@ziepe.ca>
 <20190523173302.GD5104@redhat.com>
 <20190523175546.GE12159@ziepe.ca>
 <20190523182458.GA3571@redhat.com>
 <20190523191038.GG12159@ziepe.ca>
 <20190524064051.GA28855@infradead.org>
 <20190524124455.GB16845@ziepe.ca>
 <20190525155210.8a9a66385ac8169d0e144225@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190525155210.8a9a66385ac8169d0e144225@linux-foundation.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 25, 2019 at 03:52:10PM -0700, Andrew Morton wrote:
> On Fri, 24 May 2019 09:44:55 -0300 Jason Gunthorpe <jgg@ziepe.ca> wrote:
> 
> > Now that -mm merged the basic hmm API skeleton I think running like
> > this would get us quickly to the place we all want: comprehensive in tree
> > users of hmm.
> > 
> > Andrew, would this be acceptable to you?
> 
> Sure.  Please take care not to permit this to reduce the amount of
> exposure and review which the core HMM pieces get.

Certainly, thanks all

Jerome: I started a HMM branch on v5.2-rc2 in the rdma.git here:

git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git
https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=hmm

Please send a series with the initial cross tree stuff:
 - kconfig fixing patches
 - The full removal of all the 'temporary for merging' APIs
 - Fixing the API of hmm_range_register to accept a mirror

When these are ready I'll send a hmm PR to DRM so everyone is on the
same API page.

I'll also move the hugetlb patch that Andrew picked up into this git
so we don't have a merge conflict risk

In parallel let us also finish revising the mirror API and going
through the ODP stuff.

Regards,
Jason

