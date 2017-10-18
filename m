Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57DED6B025E
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:13:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f4so2215175wme.21
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:13:43 -0700 (PDT)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id i5si67883edd.36.2017.10.18.07.13.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 07:13:42 -0700 (PDT)
Received: from mail.blacknight.com (unknown [81.17.254.10])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id C97301C2611
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 15:13:41 +0100 (IST)
Date: Wed, 18 Oct 2017 15:13:41 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [patch] mm, slab: only set __GFP_RECLAIMABLE once
Message-ID: <20171018141341.46atga2mi6eudnw2@techsingularity.net>
References: <alpine.DEB.2.10.1710171527560.140898@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710171527560.140898@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 17, 2017 at 03:30:01PM -0700, David Rientjes wrote:
> SLAB_RECLAIM_ACCOUNT is a permanent attribute of a slab cache.  Set 
> __GFP_RECLAIMABLE as part of its ->allocflags rather than check the cachep 
> flag on every page allocation.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
