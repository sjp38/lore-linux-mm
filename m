Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CAD5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 15:49:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC2832192D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 15:49:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="h9OUIip/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC2832192D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82BC08E0003; Fri, 15 Feb 2019 10:49:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B27A8E0001; Fri, 15 Feb 2019 10:49:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A3318E0003; Fri, 15 Feb 2019 10:49:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FDEF8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:49:36 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id w15so16460032ita.1
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 07:49:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gxvfq5TL/2HmGfmAumLfCM1Ftb4XqCEsXRfcSZF+1T0=;
        b=krz8JhJjY66Nlmg0FCMrhc4iEPJouj8XvYKX3ttzxJsd/VMff3MFrYQM1DvCGwh3aj
         OvKczByO6Xeu8oqD3mJX9CLsNuQzeKtGgZDU2ICG8RzmhWBrmaRrGFI/0433FHDOfJsF
         BLXhZxxxaGEkHmbTCbIzaFQArrJ4/2L5DK4qiuEUzdO7vVzQJc+6uv2Tv9KcFqsUekq3
         e2ucZmioBXaw5qFcaGtlYZkN7RNM0vKLXN+Te9UDf92T5EfQsqsVvpxeL2AYqwPMgkfE
         H5ZxOBh1VUQzUDvOkcrpmPfqGdPQLzQqGDftNma/9Rkok0hlcJrO5oZUJULOo4K3wH4M
         abKg==
X-Gm-Message-State: AHQUAubWMGrQbHz+RHzzsI1P9rqCDRwaWik0hV2yK3ewl2t2kSFtHp5m
	9ZhbcQcjOvKznmIEAx0KqTliGOjD2ay2i5r5uc/gSYAvFYvsesamnTxRE5JderppvtTNIczicni
	adtBknPdNQN88gnAWvm0jZREox3iddWtxaf0qcYkjBXAem4C9VHWK2jb3PSOhDDMtrkxmxFE5jA
	zgEa1eSxBn169JyrHVdajO/q38207IqYLLJGlXOrHy8J0H4gIZzF9+HW3j0Ep/1lA/obOTeQNEX
	z8UurslldNxAy0lhALjzvLvt42jl/LwVNfgqyI3zWs46H2pTwN417POj2cta/JXB3gvwFSG61qA
	JI9mUbuGsCZYyMDo7j2dJGK4dNjm2zJI71zvIU0HwazFCMH1Gfw5XYYoMeNNxFr7plmzudG10Po
	d
X-Received: by 2002:a6b:7514:: with SMTP id l20mr6871149ioh.120.1550245776047;
        Fri, 15 Feb 2019 07:49:36 -0800 (PST)
X-Received: by 2002:a6b:7514:: with SMTP id l20mr6871101ioh.120.1550245775210;
        Fri, 15 Feb 2019 07:49:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550245775; cv=none;
        d=google.com; s=arc-20160816;
        b=Qexl/FCvKNrbkxlPtkbwvcrkPHKjGB/3uZwkA3dIjM7dKe9SblmLSQIrhlnyGxH5ps
         ZaJiexC5daZTPtpd6MGBgfTnT79qWGV9uqywMfg/plfNC7hZaqufd4UYU3Onn6TuOkxE
         TJ2mnrTefEAVnwr+GDScKwTN4JrRt1dOaqYgoG5casWbl0D0Qmyqjfa2fOxt5WBxGBFS
         fhQPXd09r/vX/9AkMAxaRHYwUtVqeLAER9hwvORIkHEOlz8PJBmvqZQks+GVS2OyOT0c
         2ub2XWWZg+5Exw9OaB2l6kI/CLFomc/97Qxz7c59wP19NmHKdzdb0h7IaW8+P3fqr6NG
         achA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=gxvfq5TL/2HmGfmAumLfCM1Ftb4XqCEsXRfcSZF+1T0=;
        b=0c3BjYuiMv9Zjwn1eu3aLQ+Rk9my/vd7X700sazFy59Kd89MwaoHmDO6Tv1+U8PQi1
         wr6Pf4zHNwjGrKSZ3Isu9CJ0azpfGI8oM++WEbHJpy8fKw9WL0xA7IdV+lPfFETKI+40
         nnilMAswZblWQIrbEyn1xG3nNuSWXSdI/JB95ticZA2b+vQaELPDrXTfnci9TKv73GZY
         FpPb0LFMktV9uABR2+FIEmTN1/k2mk2YR9QmYIETioWWx/FlvLiXFCn2Z1B8cdZpAt8u
         mAK9zyfW2CGk23GvHznAIS1NdmUMq9DK02USmVBIP6995uR5dtzWujA2su6Fvfs6KyYD
         R4KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b="h9OUIip/";
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i34sor13712500jaf.1.2019.02.15.07.49.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 07:49:35 -0800 (PST)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b="h9OUIip/";
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=gxvfq5TL/2HmGfmAumLfCM1Ftb4XqCEsXRfcSZF+1T0=;
        b=h9OUIip/xw+IU3EFOgAuJ2mEtH+VQuLeB4N2O2e5L27iYvYrtP6ekFwJsYUVSR8Bs1
         V392XnrQeNAUy7rzEK5X9RjrKX8vmLHjqRiG5HONgjRm2+fOgE6f7wJuvX6QtuzsWOdF
         MfkNy1spvU8KVAOhzx2gB7lsHkND6yni833wB9wMTVzynMNMNsVhVjpfEHZ2/3qGsz9D
         rXvPlMf1e6MpwVMTBVf+gHJWXTWyumwVlENzGzRya5qqopY95rsZqVKBmvI+tskX1FeI
         khsRD7p9S2INbR0YIRanHv6C+VCXUUdEVjlIFSQ4S3sSSa7xj2Un1EU661Qgk61bbUHy
         K1+Q==
X-Google-Smtp-Source: AHgI3IaV0Q9G5s5V1+OIQRz7sTqwSOWc1UGhJpRZNN56AkN2+6GPnd9+jvWg/bVCGoDtKm+mPdu3Pg==
X-Received: by 2002:a02:984d:: with SMTP id x13mr4966711jaj.140.1550245774598;
        Fri, 15 Feb 2019 07:49:34 -0800 (PST)
Received: from [192.168.1.158] ([216.160.245.98])
        by smtp.gmail.com with ESMTPSA id w186sm2639569itb.15.2019.02.15.07.49.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 07:49:33 -0800 (PST)
Subject: Re: [PATCH V15 00/18] block: support multi-page bvec
To: Ming Lei <ming.lei@redhat.com>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>,
 Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>,
 Dave Chinner <dchinner@redhat.com>,
 Kent Overstreet <kent.overstreet@gmail.com>,
 Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com,
 Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
 linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>,
 linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>,
 linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>,
 Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org,
 Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org,
 Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>,
 cluster-devel@redhat.com
References: <20190215111324.30129-1-ming.lei@redhat.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <c52b6a8b-d1d4-67ff-f81c-371d09cc6d5b@kernel.dk>
Date: Fri, 15 Feb 2019 08:49:31 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/15/19 4:13 AM, Ming Lei wrote:
> Hi,
> 
> This patchset brings multi-page bvec into block layer:
> 
> 1) what is multi-page bvec?
> 
> Multipage bvecs means that one 'struct bio_bvec' can hold multiple pages
> which are physically contiguous instead of one single page used in linux
> kernel for long time.
> 
> 2) why is multi-page bvec introduced?
> 
> Kent proposed the idea[1] first. 
> 
> As system's RAM becomes much bigger than before, and huge page, transparent
> huge page and memory compaction are widely used, it is a bit easy now
> to see physically contiguous pages from fs in I/O. On the other hand, from
> block layer's view, it isn't necessary to store intermediate pages into bvec,
> and it is enough to just store the physicallly contiguous 'segment' in each
> io vector.
> 
> Also huge pages are being brought to filesystem and swap [2][6], we can
> do IO on a hugepage each time[3], which requires that one bio can transfer
> at least one huge page one time. Turns out it isn't flexiable to change
> BIO_MAX_PAGES simply[3][5]. Multipage bvec can fit in this case very well.
> As we saw, if CONFIG_THP_SWAP is enabled, BIO_MAX_PAGES can be configured
> as much bigger, such as 512, which requires at least two 4K pages for holding
> the bvec table.
> 
> With multi-page bvec:
> 
> - Inside block layer, both bio splitting and sg map can become more
> efficient than before by just traversing the physically contiguous
> 'segment' instead of each page.
> 
> - segment handling in block layer can be improved much in future since it
> should be quite easy to convert multipage bvec into segment easily. For
> example, we might just store segment in each bvec directly in future.
> 
> - bio size can be increased and it should improve some high-bandwidth IO
> case in theory[4].
> 
> - there is opportunity in future to improve memory footprint of bvecs. 
> 
> 3) how is multi-page bvec implemented in this patchset?
> 
> Patch 1 ~ 3 parpares for supporting multi-page bvec. 
> 
> Patches 4 ~ 14 implement multipage bvec in block layer:
> 
> 	- put all tricks into bvec/bio/rq iterators, and as far as
> 	drivers and fs use these standard iterators, they are happy
> 	with multipage bvec
> 
> 	- introduce bio_for_each_bvec() to iterate over multipage bvec for splitting
> 	bio and mapping sg
> 
> 	- keep current bio_for_each_segment*() to itereate over singlepage bvec and
> 	make sure current users won't be broken; especailly, convert to this
> 	new helper prototype in single patch 21 given it is bascially a mechanism
> 	conversion
> 
> 	- deal with iomap & xfs's sub-pagesize io vec in patch 13
> 
> 	- enalbe multipage bvec in patch 14 
> 
> Patch 15 redefines BIO_MAX_PAGES as 256.
> 
> Patch 16 documents usages of bio iterator helpers.
> 
> Patch 17~18 kills NO_SG_MERGE.
> 
> These patches can be found in the following git tree:
> 
> 	git:  https://github.com/ming1/linux.git  v5.0-blk_mp_bvec_v14
                                                                   ^^^

v15?

> Lots of test(blktest, xfstests, ltp io, ...) have been run with this patchset,
> and not see regression.
> 
> Thanks Christoph for reviewing the early version and providing very good
> suggestions, such as: introduce bio_init_with_vec_table(), remove another
> unnecessary helpers for cleanup and so on.
> 
> Thanks Chritoph and Omar for reviewing V10/V11/V12, and provides lots of
> helpful comments.

Applied, thanks Ming. Let's hope it sticks!

-- 
Jens Axboe

