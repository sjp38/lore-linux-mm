Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B72CFC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 07:10:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6877721852
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 07:10:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6877721852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06B658E0003; Wed, 27 Feb 2019 02:10:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F35318E0001; Wed, 27 Feb 2019 02:10:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD71A8E0003; Wed, 27 Feb 2019 02:10:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2508E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 02:10:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id a21so6604473eda.3
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 23:10:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=wLspcpdXoa972v6BbwpjFslw8oBOCLg+KkgF9KPx+xw=;
        b=oruM6yLafT+U89rkxESex5hEsRpOoFKcCaM/pOTo17crIVr3K9BrzZDvWTtrJmJPN2
         MEFzkaAspYGqjMmKqqZ+omYRhLmb/STylm7zNe+MLGmSmb4ftkEZ5P99Qe23NSOqbj/t
         i8RB3tRvXVeODg0odf3x53nx/TSPwP0KqzBWFaxxy8My22XvgtoxHSbfIBg5PvMDsk6t
         zJ0/1xxQlvRrffOkqIauVuQ4O6DiU6qmxoTaWYI4h6R/hsLYZippfeRlSeQ1yhkTpcsI
         yyxq8qatGREM/HTDji3fgovrO1NH7fD/vYMjgBDb7kruZTsWYhsnQUDm99iAFrYQk8WB
         tdCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuaXv1Aj2nzkwZOLGVZhZzl+yIxun/raBcuN3oeYO5buEGAAy+3n
	4+4i1dXoQF+ymkThkaD9V38XtvMO1I5QwGgVRsNTaugv6yqx70CZoPdfe0BDDFd2aLN4PI4oaz2
	bA8MaC5EKlfevlwpKn9EYUlMvtwdQuOw4NPr7MeCCAm8jCJKiPn9hlVYPv3QFzvAh1Q==
X-Received: by 2002:a05:6402:650:: with SMTP id u16mr1095750edx.148.1551251445071;
        Tue, 26 Feb 2019 23:10:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYC8xc6E3g5kZqrG1uSA+dSIlryamN91VZV49Vaz8oLSs4gwqL/YbCIO3irFNu8BWAKyHyR
X-Received: by 2002:a05:6402:650:: with SMTP id u16mr1095702edx.148.1551251444060;
        Tue, 26 Feb 2019 23:10:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551251444; cv=none;
        d=google.com; s=arc-20160816;
        b=fT8IVoAvdb0K+mWt/cEO3oplmNH18Q6P4sj8SF7R3OJNcSHSD61FHnugn5p87Mb84T
         I2xr9DI0BEM8nk7AiyAkEG0O6ufo6SH6nlVMQ//wBLtp1txBjpPoVKCDvpGmMVUiy0Sh
         Pq5J1iubG9VfosB2mysFe5Zzpu8fTtdvIEqE0WIFRbPf1+jMYpH/+AJH6UoJqNgvsTmM
         MAhFea4crVyWIbLGLnHl94o0rKJJKODyOm+0b/E2I0MsOWaAOVmeZIl67fz4vd+LoK3s
         2OeFxmmJLOshTdVA/w9Vt7zF1zcVUNLd8C5lUfSG6/ncvBb4SgTuzXaHgSoRzrxUZ31r
         3pPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=wLspcpdXoa972v6BbwpjFslw8oBOCLg+KkgF9KPx+xw=;
        b=nBcbrlyuEWbByKt5q5UgKQeYzjKEmVAdjnxjYFFa9PNtdFgdh5GoS9c5Iyz4PYi+dH
         WufG3FFt6WsIAOmWFMO6ogBsIK/e9y9evwGy1a7kTPgFTADB9BCABjy4V9THLJuPl9Le
         lCXj8uohxAVQMnCC+uG7hG1VJBwJCK93NJxPhjgPou2Pq61K0pUYlZeboc6mTZr8N/OV
         NcuEfhOuO8hjCnA8sO7inagM+lJ3bvlg9de7TsVjNsY56pqxElvxAh0fopMC1YYvGOES
         M91EyrE5yqfVdGWFZANrqeY+8TLul2U+iSISA8AnZrFznLIEIU+cz0av7H7hO79DufBA
         c80w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l2si5054016ejs.241.2019.02.26.23.10.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 23:10:43 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C8F49B02D;
	Wed, 27 Feb 2019 07:10:42 +0000 (UTC)
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
To: Matthew Wilcox <willy@infradead.org>,
 "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ming Lei <ming.lei@redhat.com>, Ming Lei <tom.leiming@gmail.com>,
 Dave Chinner <david@fromorbit.com>,
 "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>,
 Jens Axboe <axboe@kernel.dk>, Vitaly Kuznetsov <vkuznets@redhat.com>,
 Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
 Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm
 <linux-mm@kvack.org>, linux-block <linux-block@vger.kernel.org>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>
References: <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
 <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
 <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
 <20190226121209.GC11592@bombadil.infradead.org>
 <20190226123545.GA6163@ming.t460p>
 <20190226130230.GD11592@bombadil.infradead.org>
 <20190226134247.GA30942@ming.t460p>
 <20190226140440.GF11592@bombadil.infradead.org>
 <20190226161433.GH21626@magnolia>
 <20190226161912.GG11592@bombadil.infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <095ae112-f98e-9516-910a-43b49ea5bf0d@suse.cz>
Date: Wed, 27 Feb 2019 08:07:31 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190226161912.GG11592@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/26/19 5:19 PM, Matthew Wilcox wrote:
> On Tue, Feb 26, 2019 at 08:14:33AM -0800, Darrick J. Wong wrote:
>> On Tue, Feb 26, 2019 at 06:04:40AM -0800, Matthew Wilcox wrote:
>> Wait a minute, are you all saying that /directio/ is broken on XFS too??
>> XFS doesn't use blockdev_direct_IO anymore.
>>
>> I thought we were talking about alignment of XFS metadata buffers
>> (xfs_buf.c), which is a very different topic.
>>
>> As I understand the problem, in non-debug mode the slab caches give
>> xfs_buf chunks of memory that are aligned well enough to work, but in
>> debug mode the slabs allocate slightly more bytes to carry debug
>> information which pushes the returned address up slightly, thus breaking
>> the alignment requirements.
>>
>> So why can't we just move the debug info to the end of the object?  If
>> our 512 byte allocation turns into a (512 + a few more) bytes we'll end
>> up using 1024 bytes on the allocation regardless, so it shouldn't matter
>> to put the debug info at offset 512.  If the reason is fear that kernel
>> code will scribble off the end of the object, then return (*obj + 512).
>> Maybe you all have already covered this, though?
> 
> I don't know _what_ Ming Lei is saying.  I thought the problem was
> with slab redzones, which need to be before and after each object,
> but apparently the problem is with KASAN as well.

That's what I thought as well. But if we can solve it for caches created
by kmem_cache_create(..., align, ...) then IMHO we could guarantee
natural alignment for power-of-two kmalloc caches as well.

