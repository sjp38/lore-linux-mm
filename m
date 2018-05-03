Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11AB76B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 22:31:47 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r9-v6so7249111pgp.12
        for <linux-mm@kvack.org>; Wed, 02 May 2018 19:31:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r6si12635841pfi.147.2018.05.02.19.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 May 2018 19:31:45 -0700 (PDT)
Date: Wed, 2 May 2018 19:31:43 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 RESEND 2/2] mm: ignore memory.min of abandoned memory
 cgroups
Message-ID: <20180503023142.GA4938@bombadil.infradead.org>
References: <20180502154710.18737-1-guro@fb.com>
 <20180502154710.18737-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180502154710.18737-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Wed, May 02, 2018 at 04:47:10PM +0100, Roman Gushchin wrote:
> +				 * Abandoned cgroups are loosing protection,

"losing".
