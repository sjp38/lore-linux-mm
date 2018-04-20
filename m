Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A37716B0009
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 07:34:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a38-v6so8435454wra.10
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 04:34:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i41si2277601ede.346.2018.04.20.04.34.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 04:34:06 -0700 (PDT)
Date: Fri, 20 Apr 2018 13:34:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] treewide: use PHYS_ADDR_MAX to avoid type casting
 ULLONG_MAX
Message-ID: <20180420113404.GZ17484@dhcp22.suse.cz>
References: <20180419214204.19322-1-stefan@agner.ch>
 <20180420111510.GA10788@bombadil.infradead.org>
 <d91c35be6f85a20028910babb35243d0@agner.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d91c35be6f85a20028910babb35243d0@agner.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Agner <stefan@agner.ch>
Cc: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, catalin.marinas@arm.com, torvalds@linux-foundation.org, pasha.tatashin@oracle.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 20-04-18 13:20:10, Stefan Agner wrote:
> On 20.04.2018 13:15, Matthew Wilcox wrote:
> > On Thu, Apr 19, 2018 at 11:42:04PM +0200, Stefan Agner wrote:
> >> With PHYS_ADDR_MAX there is now a type safe variant for all
> >> bits set. Make use of it.
> > 
> > There is?  I don't see it in linux-next.
> 
> The patch "mm/memblock: introduce PHYS_ADDR_MAX" got merged earlier this
> week, should be in the -mm tree.

Andrew hasn't released his mmotm tree yet so this is not in linux-next
yet as well.
-- 
Michal Hocko
SUSE Labs
