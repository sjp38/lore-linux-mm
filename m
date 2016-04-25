Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 412DC6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 11:01:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so43531870wme.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 08:01:17 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id 11si19715555wmd.115.2016.04.25.08.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 08:01:16 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id e201so89079890wme.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 08:01:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <571DC72F.3030503@suse.cz>
References: <5715FEFD.9010001@gmail.com>
	<20160421162210.f4a50b74bc6ce886ac8c8e4e@linux-foundation.org>
	<571DC72F.3030503@suse.cz>
Date: Mon, 25 Apr 2016 17:01:15 +0200
Message-ID: <CAMJBoFN7ZFnz9-mG4Vn=Sd-p-bCdnC_H30br=JANMsoWM5Eayw@mail.gmail.com>
Subject: Re: [PATCH v2] z3fold: the 3-fold allocator for compressed pages
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>

On Mon, Apr 25, 2016 at 9:28 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 04/22/2016 01:22 AM, Andrew Morton wrote:
<snip>
>>
>> So...  why don't we just replace zbud with z3fold?  (Update the changelog
>> to answer this rather obvious question, please!)
>
>
> There was discussion between Seth and Vitaly on v1. Without me knowing the
> details myself, it looked like Seth's objections were addressed, but then
> the thread died. I think there should first be a more clear answer from Seth
> whether z3fold really looks like a clear win (i.e. not workload-dependent)
> over zbud, in which case zbud could be extended?

I have tried to address this question in the changelog for v3 which came out
today. Basically I'd like to play on the safe side and have z3fold
co-existing with
zbud for a while, since zbud is a simple and proven solution which has less
object code and can work without ZPOOL. The original zbud implementation
doesn't use struct page's fields in any way, which z3fold can't get
away without.

As a matter of fact, I don't think there's much of the similar code left between
zbud and z3fold, other than the generic structure.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
