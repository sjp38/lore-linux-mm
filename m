Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1A36B0006
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 07:20:13 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 88-v6so7220016wrc.21
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 04:20:13 -0700 (PDT)
Received: from mail.kmu-office.ch (mail.kmu-office.ch. [2a02:418:6a02::a2])
        by mx.google.com with ESMTPS id r57si1698390edd.193.2018.04.20.04.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 04:20:11 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Date: Fri, 20 Apr 2018 13:20:10 +0200
From: Stefan Agner <stefan@agner.ch>
Subject: Re: [PATCH] treewide: use PHYS_ADDR_MAX to avoid type casting
 ULLONG_MAX
In-Reply-To: <20180420111510.GA10788@bombadil.infradead.org>
References: <20180419214204.19322-1-stefan@agner.ch>
 <20180420111510.GA10788@bombadil.infradead.org>
Message-ID: <d91c35be6f85a20028910babb35243d0@agner.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, torvalds@linux-foundation.org, pasha.tatashin@oracle.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 20.04.2018 13:15, Matthew Wilcox wrote:
> On Thu, Apr 19, 2018 at 11:42:04PM +0200, Stefan Agner wrote:
>> With PHYS_ADDR_MAX there is now a type safe variant for all
>> bits set. Make use of it.
> 
> There is?  I don't see it in linux-next.

The patch "mm/memblock: introduce PHYS_ADDR_MAX" got merged earlier this
week, should be in the -mm tree.

--
Stefan
