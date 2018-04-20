Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF7C6B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 07:15:20 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q6so2698938pgv.12
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 04:15:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 17si4778290pgh.114.2018.04.20.04.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 04:15:19 -0700 (PDT)
Date: Fri, 20 Apr 2018 04:15:10 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] treewide: use PHYS_ADDR_MAX to avoid type casting
 ULLONG_MAX
Message-ID: <20180420111510.GA10788@bombadil.infradead.org>
References: <20180419214204.19322-1-stefan@agner.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180419214204.19322-1-stefan@agner.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Agner <stefan@agner.ch>
Cc: akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, torvalds@linux-foundation.org, pasha.tatashin@oracle.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 19, 2018 at 11:42:04PM +0200, Stefan Agner wrote:
> With PHYS_ADDR_MAX there is now a type safe variant for all
> bits set. Make use of it.

There is?  I don't see it in linux-next.
