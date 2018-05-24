Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DECB6B0006
	for <linux-mm@kvack.org>; Thu, 24 May 2018 14:48:52 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t17-v6so82884ply.13
        for <linux-mm@kvack.org>; Thu, 24 May 2018 11:48:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k14-v6si1762259pgn.99.2018.05.24.11.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 24 May 2018 11:48:50 -0700 (PDT)
Date: Thu, 24 May 2018 11:48:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 0/5] kmalloc-reclaimable caches
Message-ID: <20180524184846.GA5459@bombadil.infradead.org>
References: <20180524110011.1940-1-vbabka@suse.cz>
 <20180524114350.GA10323@bombadil.infradead.org>
 <0944e1ed-60fe-36ce-ea06-936b3f595d5f@infradead.org>
 <cfb7c8df-2a6a-bf84-8a30-df97c58c9c47@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cfb7c8df-2a6a-bf84-8a30-df97c58c9c47@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>

On Thu, May 24, 2018 at 11:40:59AM -0700, Randy Dunlap wrote:
> >> 	while (size > 1024) {
> 
> I would use   (size >= 1024)
> so that 1M is printed instead of 1024K.

Yes; that's what I meant to type.  Thanks!
