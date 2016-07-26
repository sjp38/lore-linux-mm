Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B0E806B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 03:31:02 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so134703731lfi.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 00:31:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l135si27723399wmg.133.2016.07.26.00.31.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jul 2016 00:31:01 -0700 (PDT)
Subject: Re: [PATCH v2] mm: page-flags: Use bool return value instead of int
 for all XXPageXXX functions
References: <1469336184-1904-1-git-send-email-chengang@emindsoft.com.cn>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <13e3f511-e14c-2e4d-9627-4a85c65de931@suse.cz>
Date: Tue, 26 Jul 2016 09:30:52 +0200
MIME-Version: 1.0
In-Reply-To: <1469336184-1904-1-git-send-email-chengang@emindsoft.com.cn>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chengang@emindsoft.com.cn, akpm@linux-foundation.org, minchan@kernel.org, mgorman@techsingularity.net, mhocko@suse.com
Cc: gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 07/24/2016 06:56 AM, chengang@emindsoft.com.cn wrote:
> From: Chen Gang <gang.chen.5i5j@gmail.com>
>
> For pure bool function's return value, bool is a little better more or
> less than int.

That's not exactly a bulletproof justification... At least provide a 
scripts/bloat-o-meter output?

> Under source root directory, use `grep -rn Page * | grep "\<int\>"` to
> find the area that need be changed.
>
> For the related macro function definiations (e.g. TESTPAGEFLAG), they
> use xxx_bit which should be pure bool functions, too. But under most of
> architectures, xxx_bit are return int, which need be changed next.

Sounds like a large task. And until we know the arches will agree with 
this, this patch will bring just inconsistency?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
