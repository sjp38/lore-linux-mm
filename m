Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAAF6C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:36:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 973DC2084E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:36:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="EDamHHKF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 973DC2084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 310958E0008; Wed, 19 Jun 2019 12:36:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C05A8E0001; Wed, 19 Jun 2019 12:36:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AFA18E0008; Wed, 19 Jun 2019 12:36:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC6BE8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:36:57 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so16546980qtb.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:36:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DzpNw7iMfHgKemdLUrfJxvdy9KGKJSIkCkr6aus8rCA=;
        b=VurhcEsSdV13Itw338DxB7XI3QM2MUBq4M9f2rsi8xGr5OPX0nE48inIdRyv2SuE9a
         uYb7YM6Mn5Y49Sm3GLgIClYolixmO1v2NefervdhjbZwh+rKg3YhMJ9MOhLe8Vl6MLxs
         Jk6zZAkqzh4anF0iAUfRZz1zD+Ll0WDT+XCHL8OG5X20UtiLqRx49hiUOpTXcqpAQyUN
         qyhekL/6w2/zLVXNr7wAg5N+0uOJicBsgRjVcylRWdWE2ECRhGds5TJQzkkZYsS0DS/Z
         ZeQ1AgHv+n9MSVEuye3Cr4SSBt74ph5BBEwlf6gwboj5OzuIEp7WJxDrYxGVuHH29QVT
         ao5A==
X-Gm-Message-State: APjAAAUJPFhiSKpjr17v7s9mS2RCRNqirANOgovm+TiteP8NMijURqNw
	554RqJEH92CFo+3fyzJtwEnhPCFUPm48gUqyF3doGftTIoh0VMD7ybkJ74KCajC3PRZOobl5yP1
	/fQvHHnaXBBbvUD/CSd5iApJihG0hr7niif1Z5ftl+zmzWMZee9SL3QOU4xIrysLLIA==
X-Received: by 2002:ac8:16ac:: with SMTP id r41mr107957617qtj.346.1560962217715;
        Wed, 19 Jun 2019 09:36:57 -0700 (PDT)
X-Received: by 2002:ac8:16ac:: with SMTP id r41mr107957570qtj.346.1560962217163;
        Wed, 19 Jun 2019 09:36:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560962217; cv=none;
        d=google.com; s=arc-20160816;
        b=wCFD7cWb5x2CoIb/KeHS/LPHTHraFj/fWkClPg5CP3obLPhrpEDRIopR8x1cwOaNbQ
         fb7ESwQPYwuh1TuiblUu9Pfyp+BrcKVHZGE9l+FF5mVlz5FnD0wQDy68MJg4j0BPbLZh
         vcV7VjpE5XRkR0g3lDVcdwMu/X9GAqpH7craZNLlWV3qWPSG17rXA15DhA+yZHz9zsh3
         NEJNyjyC3Bl/Quds1shST04ODLDAlyL2XuvSsj8TJN6qiFajWmpR/rQ3cCuKtgHdi8Vq
         CiwZRmxnpaoovcIktk6X4Ks9IU1PXd4NGbgci2+cCj2N8PaPJ3RJJ5Xl0l9PGPLSQLBw
         3jMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DzpNw7iMfHgKemdLUrfJxvdy9KGKJSIkCkr6aus8rCA=;
        b=v9Uqaw/monxfXnKxuWb7aRfJUsiKmPGIFkzhOiFZRnLm9ODyyIlX2oLcQe9aYdBpvb
         XmQyQc8VzrZdkrEkTSd3LaJA30GTeHTDbKz9r+Ozwc2U4AP8FBelBbibd+JbLcxzwg96
         dNciyvH1BnHJiR4wzcgyec7P22Li8nCLgsaCpL9NkczvZOne99/aevmWRQYljcDjcDVX
         X2Y/avnRof+BTP2xwip5i50jQJUnGpJhn16n7k4LJZ7FDKJ5JCpHw+UyIM3Y3K9xjnhE
         1LkqjA8LDXofHHH/zyp9BF8zRH0qi2uVfbQ23UCNpfNAOFimsjBPUyLFBLBhMbrzaqDM
         HXEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EDamHHKF;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n24sor16294612qvd.2.2019.06.19.09.36.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 09:36:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EDamHHKF;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DzpNw7iMfHgKemdLUrfJxvdy9KGKJSIkCkr6aus8rCA=;
        b=EDamHHKFiI7TTHkw3d71MrV0NdBwB6F1R0bV3XkjGbuH5mQMYmiVlZa63N43certmw
         GaIE2u+163Cb4BhvTpbwTBxOWcLAcGEeI/3LO9nZ2D3hphDdktczve9XtPtWbb/zjdgx
         QuoJYZuWKxQ1Q1HWKQMOXlDG8688RHVxOe9ZrXX0wEZogGnlfFfLqDn8V5Dbs8IQvczi
         yQX28xdFN722tg0xFkBas291DRO6iaiEm0BDaeD7B2Eul7XBDtVnG/ZeKQsPeS/6vBSl
         FO7l2jZl3LYlQIBoVhkk/uCuTaMtyaMfsLTID0dqUBuf/FNrb2Plto9Q3eXvKdPYCYXn
         mxug==
X-Google-Smtp-Source: APXvYqzqHRHHrr8SACyRyLxcASgrxSvjDf6v3XwfN8DQX4ZVR7KLVzKliqO65H7tJkj2zv0u+29foQ==
X-Received: by 2002:a0c:d24d:: with SMTP id o13mr34947576qvh.86.1560962216870;
        Wed, 19 Jun 2019 09:36:56 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r36sm11720396qte.71.2019.06.19.09.36.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 09:36:56 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hddZv-0001vf-QN; Wed, 19 Jun 2019 13:36:55 -0300
Date: Wed, 19 Jun 2019 13:36:55 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>,
	nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: dev_pagemap related cleanups v2
Message-ID: <20190619163655.GG9360@ziepe.ca>
References: <20190617122733.22432-1-hch@lst.de>
 <CAPcyv4hBUJB2RxkDqHkfEGCupDdXfQSrEJmAdhLFwnDOwt8Lig@mail.gmail.com>
 <20190619094032.GA8928@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619094032.GA8928@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 11:40:32AM +0200, Christoph Hellwig wrote:
> On Tue, Jun 18, 2019 at 12:47:10PM -0700, Dan Williams wrote:
> > > Git tree:
> > >
> > >     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup.2
> > >
> > > Gitweb:
> > >
> > >     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-devmem-cleanup.2
> 
> > 
> > Attached is my incremental fixups on top of this series, with those
> > integrated you can add:
> 
> I've folded your incremental bits in and pushed out a new
> hmm-devmem-cleanup.3 to the repo above.  Let me know if I didn't mess
> up anything else.  I'll wait for a few more comments and Jason's
> planned rebase of the hmm branch before reposting.

I said I wouldn't rebase the hmm.git (as it needs to go to DRM, AMD
and RDMA git trees)..

Instead I will merge v5.2-rc5 to the tree before applying this series.

I've understood this to be Linus's prefered workflow.

So, please send the next iteration of this against either
plainv5.2-rc5 or v5.2-rc5 merged with hmm.git and I'll sort it out.

Jason

