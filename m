Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F565C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 10:06:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC7752173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 10:06:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC7752173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E22E8E0003; Tue, 26 Feb 2019 05:06:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46A9E8E0001; Tue, 26 Feb 2019 05:06:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BE848E0003; Tue, 26 Feb 2019 05:06:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C2AE08E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 05:06:17 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e46so5273615ede.9
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:06:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=fPjyG/sj84TjOhFrLomGnIeWnO77IwIcYYljQwFkCkg=;
        b=YOdTem3Gp9K5i97oX46C3pIH7l+XgLvYZqsKTJCc1o/8HRPeFelQa2uT0BB0GFIHS2
         Ly6WxifCJQXhjfB2EULyKEqk4Aj9P3AsFeZjFh3XTGtxCPL861eqI7sbqJmRFLd2OPgO
         OXLG2JSjmGxu2UYEGyMQFVgfoXHjditVG5Ao1PFj/SfMVriCh6DhJVK/cxb05Nfz87TR
         +PMk75h1LrT4wTW8YceOuHP+03IAyY33jdWlU1ECqm9MXvDm6Ex+v7B/MO/nQDiQuBBM
         58BCrnuR5yuSFk1BQMMBZm5eDuw9O5sgdgsRApMtyxZSPrB8DLRFp120N21CyVG+az8j
         h5eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuYAmKlKUqvlIWc+2KzI20SCokid3TmzFUeATWjXLNV4IeNCdFYF
	t14Xiu02rj6IlXtqpaCgCT50gFBB/JdJAD+hWyJxVRuYKkxXcHsS/RbB/LN5Z8FdJ0UED+s6BFL
	bue2RTNeBD8B5S8R+sQKPtOGc2ar5E+qF4iiC39YizRLNBnG8HYXzubMUZszvP2gDqw==
X-Received: by 2002:a17:906:90da:: with SMTP id v26mr16405531ejw.146.1551175577349;
        Tue, 26 Feb 2019 02:06:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYTM5aw82jpi1CzzClsivSlUkby9k7tI30sELPUeR2idfvu6LWDgqso1dTkV5nhH+KiHfzS
X-Received: by 2002:a17:906:90da:: with SMTP id v26mr16405462ejw.146.1551175575969;
        Tue, 26 Feb 2019 02:06:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551175575; cv=none;
        d=google.com; s=arc-20160816;
        b=V57i2d+XaHdD17XxB7+WrThXcHa64FUhsSVELAw+9Be3OaUUscW/PCGvdkrP4J/KvI
         JKBmO0R5sObVaJy5vXa1YQuEuaKaLi6Dsg/YuRzXKdHeWfqVhULKTZXOpfMeiTxYNQow
         8V4LuujoMI8SDjkTDkEy07qdU/CZVo7Bu3KEUw2dJKmRF5eDVlAumq39Fn+x3pN8nuOT
         O3y7L6RWDnlmGuq+qg9pOmsLmV5vWB7ieljMcEuA2j/LGAoMagl6S1lar6KUohYmvGTQ
         vkoZls6z5j7I23IAuyoxspVp5FBfl6UDAT6ABJEmDNHUGq+vQ0Qz73AWlQzCMGMxWlZ0
         Nnyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=fPjyG/sj84TjOhFrLomGnIeWnO77IwIcYYljQwFkCkg=;
        b=IWgnoSQw2NQqqxOy4bB+SAKeWNlhqi9tHPULVyaMhrcxUAkeQZkGeRvRhnSLevn0sM
         2HiVQgiRQtm9ha2DY+yynayecORXNdiCJex/zD6WMTRuvjvt4esXJqKacNBn9pQ+5QZ+
         CtbsIS5fBavOJrtlY7XcqtlPysobL0DrzzTKgb9FP5P2CHET2iBTgJ+lX0Gv3HVrpdSv
         XceIzRd+9PBMkDPMCo3cNBmiWJ+wyMSoSdzkMaM1QpdZPbwhIqiilfWSGq7gD3OsmyPZ
         BHmU+UakGoBr/EoE93dL64Hft39GCnnBDF76uDVLkOzcVAQwIFTYfrliMtWqzXfXWkgr
         xdDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gw24si4140114ejb.142.2019.02.26.02.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 02:06:15 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F1A58AEA9;
	Tue, 26 Feb 2019 10:06:14 +0000 (UTC)
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
To: Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>,
 "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org,
 Jens Axboe <axboe@kernel.dk>, Vitaly Kuznetsov <vkuznets@redhat.com>,
 Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
 Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
 linux-block@vger.kernel.org, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard> <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard> <20190226093302.GA24879@ming.t460p>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
Date: Tue, 26 Feb 2019 11:06:12 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190226093302.GA24879@ming.t460p>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/26/19 10:33 AM, Ming Lei wrote:
> On Tue, Feb 26, 2019 at 03:58:26PM +1100, Dave Chinner wrote:
>> On Mon, Feb 25, 2019 at 07:27:37PM -0800, Matthew Wilcox wrote:
>>> On Tue, Feb 26, 2019 at 02:02:14PM +1100, Dave Chinner wrote:
>>>>> Or what is the exact size of sub-page IO in xfs most of time? For
>>>>
>>>> Determined by mkfs parameters. Any power of 2 between 512 bytes and
>>>> 64kB needs to be supported. e.g:
>>>>
>>>> # mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....
>>>>
>>>> will have metadata that is sector sized (512 bytes), filesystem
>>>> block sized (1k), directory block sized (8k) and inode cluster sized
>>>> (32k), and will use all of them in large quantities.
>>>
>>> If XFS is going to use each of these in large quantities, then it doesn't
>>> seem unreasonable for XFS to create a slab for each type of metadata?
>>
>>
>> Well, that is the question, isn't it? How many other filesystems
>> will want to make similar "don't use entire pages just for 4k of
>> metadata" optimisations as 64k page size machines become more
>> common? There are others that have the same "use slab for sector
>> aligned IO" which will fall foul of the same problem that has been
>> reported for XFS....
>>
>> If nobody else cares/wants it, then it can be XFS only. But it's
>> only fair we address the "will it be useful to others" question
>> first.....
> 
> This kind of slab cache should have been global, just like interface of
> kmalloc(size).
> 
> However, the alignment requirement depends on block device's block size,
> then it becomes hard to implement as genera interface, for example:
> 
> 	block size: 512, 1024, 2048, 4096
> 	slab size: 512*N, 0 < N < PAGE_SIZE/512
> 
> For 4k page size, 28(7*4) slabs need to be created, and 64k page size
> needs to create 127*4 slabs.
>

Where does the '*4' multiplier come from?

So I wonder how hard would it actually be (+CC slab maintainers) to just
guarantee generic kmalloc() alignment for power-of-two sizes. If we can
do that for kmem_cache_create() then the code should be already there.
AFAIK the alignment happens anyway (albeit not guaranteed) in the
non-debug cases, and if guaranteeing alignment for certain debugging
configurations (that need some space before the object) means larger
memory overhead, then the cost should still be bearable since its
non-standard configuration where the point is to catch bug and not have
peak performance?

> But, specific file system may only use some of them, and it depends
> on meta data size.
> 
> Thanks,
> Ming
> 

