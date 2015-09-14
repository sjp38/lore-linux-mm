Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id D40146B0265
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 10:02:02 -0400 (EDT)
Received: by lamp12 with SMTP id p12so86429227lam.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 07:02:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex4si17381831wic.11.2015.09.14.07.02.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Sep 2015 07:02:01 -0700 (PDT)
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F6D356.5000106@suse.cz>
Date: Mon, 14 Sep 2015 16:01:58 +0200
MIME-Version: 1.0
In-Reply-To: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>, minchan@kernel.org, sergey.senozhatsky@gmail.com, ddstreet@ieee.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/14/2015 03:49 PM, Vitaly Wool wrote:
> While using ZRAM on a small RAM footprint devices, together with
> KSM,
> I ran into several occasions when moving pages from compressed swap back
> into the "normal" part of RAM caused significant latencies in system

I'm sure Minchan will want to hear the details of that :)

> operation. By using zbud I lose in compression ratio but gain in
> determinism, lower latencies and lower fragmentation, so in the coming

I doubt the "lower fragmentation" part given what I've read about the 
design of zbud and zsmalloc?

> patches I tried to generalize what I've done to enable zbud for zram so far.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
