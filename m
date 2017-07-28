Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E11896B056B
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 15:52:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 92so39595067wra.11
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 12:52:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z15si15190179edj.501.2017.07.28.12.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 28 Jul 2017 12:52:42 -0700 (PDT)
Date: Fri, 28 Jul 2017 15:52:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: Use int for event/state parameter in
 several functions
Message-ID: <20170728195236.GA22303@cmpxchg.org>
References: <20170727211004.34435-1-mka@chromium.org>
 <20170728182354.GC84665@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170728182354.GC84665@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>

On Fri, Jul 28, 2017 at 11:23:54AM -0700, Matthias Kaehlcke wrote:
> El Thu, Jul 27, 2017 at 02:10:04PM -0700 Matthias Kaehlcke ha dit:
> 
> > Several functions use an enum type as parameter for an event/state,
> > but are called in some locations with an argument of a different enum
> > type. Adjust the interface of these functions to reality by changing the
> > parameter to int.
> > 
> > This fixes a ton of enum-conversion warnings that are generated when
> > building the kernel with clang.

Thanks for fixing this, Matthias.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> While building for another target with a different configuration I
> noticed that inc/dec/mod_memcg_page_state() are also called with a
> conflicting enum type. Changing the parameter type for these functions
> also would make the API more consistent, with the current patch there
> is a somewhat odd mix of related functions, with some receiving an
> enum and others an int.
> 
> Depending on your preference I can send a v3 of this patch or a
> separate patch to address the remaining functions (since this patch
> has already been added to -mm).

Since it's the exact same rationale for the other functions, it would
make sense to me to do a v3 that includes the remaining sites.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
