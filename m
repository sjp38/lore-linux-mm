Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C72D8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:48:42 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v11so4189181ply.4
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 06:48:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i198si4904850pfe.289.2018.12.21.06.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Dec 2018 06:48:41 -0800 (PST)
Date: Fri, 21 Dec 2018 06:48:40 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Refactor readahead defines in mm.h
Message-ID: <20181221144840.GB10600@bombadil.infradead.org>
References: <20181221144053.24318-1-nborisov@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221144053.24318-1-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Fri, Dec 21, 2018 at 04:40:53PM +0200, Nikolay Borisov wrote:
> All users of VM_MAX_READAHEAD actually convert it to kbytes and then to
> pages. Define the macro explicitly as (SZ_128K / PAGE_SIZE). This
> simplifies the expression in every filesystem. Also rename the macro to
> VM_READAHEAD_PAGES to properly convey its meaning. Finally remove unused
> VM_MIN_READAHEAD
> 
> Signed-off-by: Nikolay Borisov <nborisov@suse.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>
