Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C50FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 07:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3CB9218D8
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 07:42:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3CB9218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21C826B0003; Thu, 21 Mar 2019 03:42:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A5C96B0006; Thu, 21 Mar 2019 03:42:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 070186B0007; Thu, 21 Mar 2019 03:42:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A4EC46B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 03:42:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y17so294020edd.20
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 00:42:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=XUfB/fgCisDkoqkNaBUzTUlhIh1Txg/bNOdym6ASioY=;
        b=RkZAK9OkiaCYRkw85Xo+ZCWsJgiBUwVR9uDJKvynVt2lwmGJvNvgLP8Yx7N6SufMwF
         AXXcRui7n+jf89qOdMWahwyWy3/H7aaY1s1plVKERmpNxOa8SsVkGQG6LN1Ze9OaQxoE
         mu3yHohzwKTgyJe8c+OUnj0UYcXMT0MrxqPAF3lp0Yd15X3ix06U/mrVnQ64zOKTsJsE
         Tb/2SJ0cbHgZF3djQgyD9Z+lDQODtOaiRYOSkF2rR3ji/GDFt70VNZ8Cfb4ZPI7VCs+m
         tpGfCNYYgduJZpP96pFPLyE8Nl/13h6lJ1/EPnwsEmZ1/yCBgATTznO4QvDmAD41rLfO
         meIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXRQ1ZSufMCpnqUdR9jBwfnJqbxRV9D97AYLA7NbiLauv5C4D8s
	t/dxi/GxDcUkrLj5hns+88iVuZtaV31K+frRCg7BYxlbAluEKFB3TV2a+8utWKC+IC6z21iXClb
	O2Iy4BhE4uvk6j21p8QAgOqwA/H97N2SsAre5zsyxGcklcnCqIMMeoPULPmTkKdAmBA==
X-Received: by 2002:a50:94fa:: with SMTP id t55mr1469594eda.229.1553154128222;
        Thu, 21 Mar 2019 00:42:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTurtcmZJoJoDawDsG5Vp42bPxA7iMDedlDQAcJDraH9HNd67HdfzMnbZohmE25OAbXmyj
X-Received: by 2002:a50:94fa:: with SMTP id t55mr1469543eda.229.1553154127013;
        Thu, 21 Mar 2019 00:42:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553154127; cv=none;
        d=google.com; s=arc-20160816;
        b=N7GTD09ZMSoz42hl3ONvbYEigDmA21kmlU/HqRZ1xpOOMIsvXDMtLMxF9ZH18DQ7qv
         v+WWoNk9t5YG07kfq8eNUM4Ho+XxzXYtoyaE3/WdYTPgCYgfIAy5zyNOrHxaXmbVtNtb
         SolVHi1lpiGCfM41hX4A+JRWbdCya0xyXT1gJ6g5rZFSnqZROgYXc8SYuVM+PfbS3PIx
         Y71meeZdK0+Snan0xyQt6kQcRFYu4o6EhEkby0RbJhmXd3jpaEbe/iWJ4D38+QqYsgFd
         ic4KvLkCLTxJOvymtmvp0rS8dxNRqBD0fi+H0bjNM/nPwWcP70SnR54Vy1XQVeQgwG0M
         Yq/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=XUfB/fgCisDkoqkNaBUzTUlhIh1Txg/bNOdym6ASioY=;
        b=eK85r8XAsrHdZPCKfNr12+8qLFhdqyRcCl9ax1CH3lkO6le1kiWb2LjOl9YcYJpO0w
         iaHN72bCPBRAMJLHUyBgy0Wf4ox4VlZA7m4VJsbX4qTKHAbTnSt+9G6AuGXDL07AtJsr
         KubxcaMUYWL3+nw/YfxwsUC3FEaNbfnLCiYCJDrqjyrsVyXjAVdH19pT6dvFNY77aI8/
         V/6tQQa9FD5Q2kb4/rjIcfIeBFGat08rjCOkSlLXcl/S1Jmx/X78dFp481GtgwcKMJEH
         md+lLbesQP+2vHfz+j66ctYd8+LNlQTmVaRQhr00/VEsGTw9GbXitxTz65wKePCXLrQp
         W/eQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1si80672ejs.138.2019.03.21.00.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 00:42:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 22E5DAF6A;
	Thu, 21 Mar 2019 07:42:05 +0000 (UTC)
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
 Matthew Wilcox <willy@infradead.org>,
 "Darrick J . Wong" <darrick.wong@oracle.com>, Christoph Hellwig
 <hch@lst.de>, Michal Hocko <mhocko@kernel.org>,
 linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
References: <20190319211108.15495-1-vbabka@suse.cz>
 <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com>
 <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz>
 <010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@email.amazonses.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <4d2a55dc-b29f-1309-0a8e-83b057e186e6@suse.cz>
Date: Thu, 21 Mar 2019 08:42:02 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/20/19 7:20 PM, Christopher Lameter wrote:
>>> Currently all kmalloc objects are aligned to KMALLOC_MIN_ALIGN. That will
>>> no longer be the case and alignments will become inconsistent.
>>
>> KMALLOC_MIN_ALIGN is still the minimum, but in practice it's larger
>> which is not a problem.
> 
> "In practice" refers to the current way that slab allocators arrange
> objects within the page. They are free to do otherwise if new ideas come
> up for object arrangements etc.
> 
> The slab allocators already may have to store data in addition to the user
> accessible part (f.e. for RCU or ctor). The "natural alighnment" of a
> power of 2 cache is no longer as you expect for these cases. Debugging is
> not the only case where we extend the object.

For plain kmalloc() caches, RCU and ctors don't apply, right.

>> Also let me stress again that nothing really changes except for SLOB,
>> and SLUB with debug options. The natural alignment for power-of-two
>> sizes already happens as SLAB and SLUB both allocate objects starting on
>> the page boundary. So people make assumptions based on that, and then
>> break with SLOB, or SLUB with debug. This patch just prevents that
>> breakage by guaranteeing those natural assumptions at all times.
> 
> As explained before there is nothing "natural" here. Doing so restricts
> future features

Well, future features will have to deal with the existing named caches
created with specific alignment.

> and creates a mess within the allocator of exceptions for
> debuggin etc etc (see what happened to SLAB).

SLAB could be fixed, just nobody cares enough I guess. If I want to
debug wrong SL*B usage I'll use SLUB.

> "Natural" is just a
> simplistic thought of a user how he would arrange power of 2 objects.
> These assumption should not be made but specified explicitly.

Patch 1 does this explicitly for plain kmalloc(). It's unrealistic to
add 'align' parameter to plain kmalloc() as that would have to create
caches on-demand for 'new' values of align parameter.

>>> I think its valuable that alignment requirements need to be explicitly
>>> requested.
>>
>> That's still possible for named caches created by kmem_cache_create().
> 
> So lets leave it as it is now then.

That however doesn't work well for the xfs/IO case where block sizes are
not known in advance:

https://lore.kernel.org/linux-fsdevel/20190225040904.5557-1-ming.lei@redhat.com/T/#ec3a292c358d05a6b29cc4a9ce3ae6b2faf31a23f

