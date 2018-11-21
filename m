Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 242E26B27D4
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 17:10:37 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so3667781ede.19
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 14:10:37 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si4378019edt.45.2018.11.21.14.10.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 14:10:35 -0800 (PST)
Subject: Re: [PATCH 2/4] mm: Move zone watermark accesses behind an accessor
References: <20181121101414.21301-1-mgorman@techsingularity.net>
 <20181121101414.21301-3-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <340eecec-347b-e9c2-58ff-2a8e837291b5@suse.cz>
Date: Wed, 21 Nov 2018 23:07:41 +0100
MIME-Version: 1.0
In-Reply-To: <20181121101414.21301-3-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 11/21/18 11:14 AM, Mel Gorman wrote:
> This is a preparation patch only, no functional change.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
