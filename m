Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDE368E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 07:14:02 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id u17so4019556pgn.17
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 04:14:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p11si66489554pgb.219.2019.01.09.04.14.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 Jan 2019 04:14:01 -0800 (PST)
Date: Wed, 9 Jan 2019 04:13:52 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/slub.c: re-randomize random_seq if necessary
Message-ID: <20190109121352.GI6310@bombadil.infradead.org>
References: <20190109090628.1695-1-rocking@whu.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190109090628.1695-1-rocking@whu.edu.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peng Wang <rocking@whu.edu.cn>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 09, 2019 at 05:06:27PM +0800, Peng Wang wrote:
> calculate_sizes() could be called in several places
> like (red_zone/poison/order/store_user)_store() while
> random_seq remains unchanged.
> 
> If random_seq is not NULL in calculate_sizes(), re-randomize it.

Why do we want to re-randomise the slab at these points?
