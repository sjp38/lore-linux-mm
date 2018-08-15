Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 15D1B6B0003
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 05:30:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g11-v6so373813edi.8
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 02:30:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2-v6si1164453edm.144.2018.08.15.02.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 02:30:34 -0700 (PDT)
Date: Wed, 15 Aug 2018 11:30:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] docs/core-api: add memory allocation guide
Message-ID: <20180815093032.GQ32645@dhcp22.suse.cz>
References: <1534314887-9202-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180815063649.GB24091@rapoport-lnx>
 <20180815081539.GN32645@dhcp22.suse.cz>
 <20180815090428.GD24091@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815090428.GD24091@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 15-08-18 12:04:29, Mike Rapoport wrote:
[...]
> How about:
> 
> * If the allocation is performed from an atomic context, e.g interrupt
>   handler, use ``GFP_NOWARN``. This flag prevents direct reclaim and IO or
>   filesystem operations. Consequently, under memory pressure ``GFP_NOWARN``
>   allocation is likely to fail.

s@NOWARN@NOWAIT@ I guess. Looks good otherwise. I would even go and
mention GFP_NOWARN once you brought it up. Allocations which have a
reasonable fallback should be using NOWARN.

> * If you think that accessing memory reserves is justified and the kernel
>   will be stressed unless allocation succeeds, you may use ``GFP_ATOMIC``.

OK otherwise.
-- 
Michal Hocko
SUSE Labs
