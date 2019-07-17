Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1A63C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 18:30:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 312AC2184E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 18:30:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1OMBw+NN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 312AC2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B68276B0007; Wed, 17 Jul 2019 14:30:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF2118E0003; Wed, 17 Jul 2019 14:30:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 992278E0001; Wed, 17 Jul 2019 14:30:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 603276B0007
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:30:05 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 91so12452534pla.7
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 11:30:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:dkim-signature:from:in-reply-to
         :references:message-id:date:to:cc;
        bh=4uscIpr3UDb/5ht7LxjLkEZo5xn98y28ICOEDr/zE/I=;
        b=sHppADAjzkVcPNA1R+C7rvb4qWChVUh1hgxh7oYmM6s4YXa5lQly/i1DReBCWOpjIR
         SGvBi1ddIzgzV9TiaP7AdtuuSatwqB/q7sQeBiCwfaOa1Vg9jeN3JxI4/zWK4z9hDrV0
         xIv8xPkS/FNMccA2+W8LQ7Nghm/GeWs4YCntA/K4SqMpvl1tstFiV7HzskqO2xIufqSC
         zc+Brw/EtgNcWSCAAzSjG1afxKF8ZImYzPV1PT6ve7ivw1YPs5JRu0StHDwaEK5KltPl
         QUovfdHZsPmgpYjGXH90jyxpxKt86Z9SddQ2P3KLf3x8beJhZUW5IBSTVZBdAMdalEBt
         7foA==
X-Gm-Message-State: APjAAAVJ6EmwXZNzSOxro7vk7ZOO0g575wSjGxtrflGSPaDclo1bHpV2
	muEHz/Mxn2bKUeTAfKNvenGSkaD64FafvyG4iXlhH6CBAXn+x3pYnJYyrom22KNgj/nnLFiGTNi
	kfnPGZMB2Yeaoyoxk8QD24Da66sZ+L9kLDnaxq+8LTV27HDzwOPP0EIHoxPBSAOafPg==
X-Received: by 2002:a17:902:ea:: with SMTP id a97mr44570657pla.182.1563388204947;
        Wed, 17 Jul 2019 11:30:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw49viXWZH9YD8sQNAtxVl56gNh080IUc5HJsoGSe0BQVDdscBSxxsq95x0RK21RJk3yNHv
X-Received: by 2002:a17:902:ea:: with SMTP id a97mr44570595pla.182.1563388204317;
        Wed, 17 Jul 2019 11:30:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563388204; cv=none;
        d=google.com; s=arc-20160816;
        b=kG96Ad6bsThi3jhTWv03h4bNSAgl/nDBOIdb9jaalPboxKgR2w7CKv9m9UaSxY4rBU
         skZXHBotApjO28AOBiPHpUteUF3Z+h9328xJiIm8QkS8ejx3vDMNhaarpjaErplsotSo
         6gyLPET+OaROR80uG57x+vFapEvZ1/gyte5tHW/t3Hg4Y0Yy3H7PEYabnUrh3KculW5J
         T0ZJlwkrGnLE5kE6EWG4/3gkGVQupjd4ezI0K7dsNbBhKw0Lc7IFCqQLPLTfvDJjg5QE
         MiibKygzkuoSDlyeBOjBQbyZADiIjv4JOifgi9a0gm2MKypO/3rLZuHKMbty2vdrRx9r
         em2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:date:message-id:references:in-reply-to:from:dkim-signature
         :subject;
        bh=4uscIpr3UDb/5ht7LxjLkEZo5xn98y28ICOEDr/zE/I=;
        b=HMIWVGdwwPcljUw/5zpcSbCXguBXzLvQLJiUxZtBRYwTpUNnLFdCGtJGnIhIppGG29
         Fby8mYEWtXLfZNlcR4zEO/a+KuXJNR15pONgr14b5vpxVKWlyZ2DGCfebxrK05K0k1x8
         PV2XxFPDKRnmXlb6ZZvUp1GR7xjdVPy+vsOEatqJ9rL+4K3Szd0blypgB9+AwELxjJRk
         vQ8EWebTZRR17TVAddo8m5gSJuQS0qHSQ2DAJtbzCOeFRxtgnC29fCVsG5GE4nT7WzwK
         BPpNi6h2+whdLOA2wMNWPNPwIcQHlrYozwoj2O39YC4ci+Y6esQFMlpqJDnQIPQ/jQoh
         U/lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1OMBw+NN;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y8si57693pji.65.2019.07.17.11.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 11:30:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1OMBw+NN;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Subject: Re: [PULL] virtio, vhost: fixes, features, performance
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563388203;
	bh=SsgEQ229BFDzVjWE4Rfd94cxbm2rr6++cJP0jupJNlI=;
	h=From:In-Reply-To:References:Date:To:Cc:From;
	b=1OMBw+NNcoYT1euAQa76cEb1EnJLTbURZO01B9VLtWDbz6o2ygQuSEU/k5bwly/JN
	 I9WKTyRViJihLBuveQwr15VdePBK/oENdwCbcZIOCueP649B9L4SUwnKWdXebZmJ3r
	 0AOCFDDnCBkwuFhQ3rgUh397M2+y0SfUzso6xWjs=
From: pr-tracker-bot@kernel.org
In-Reply-To: <20190716113151-mutt-send-email-mst@kernel.org>
References: <20190716113151-mutt-send-email-mst@kernel.org>
X-PR-Tracked-List-Id: <linux-parisc.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190716113151-mutt-send-email-mst@kernel.org>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus
X-PR-Tracked-Commit-Id: 5e663f0410fa2f355042209154029842ba1abd43
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 3a1d5384b7decbff6519daa9c65a35665e227323
Message-Id: <156338820366.716.10416228849149522179.pr-tracker-bot@kernel.org>
Date: Wed, 17 Jul 2019 18:30:03 +0000
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, 
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 aarcange@redhat.com, bharat.bhushan@nxp.com, bhelgaas@google.com,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-parisc@vger.kernel.org, davem@davemloft.net,
 eric.auger@redhat.com, gustavo@embeddedor.com, hch@infradead.org,
 ihor.matushchak@foobox.net, James.Bottomley@hansenpartnership.com,
 jasowang@redhat.com, jean-philippe.brucker@arm.com,
 jglisse@redhat.com, mst@redhat.com, natechancellor@gmail.com
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pull request you sent on Tue, 16 Jul 2019 11:31:51 -0400:

> git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/3a1d5384b7decbff6519daa9c65a35665e227323

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker

