Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE28828DF
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:56:01 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id r129so49428972wmr.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 17:56:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f193si7817944wmd.24.2016.01.28.17.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 17:56:00 -0800 (PST)
Date: Thu, 28 Jan 2016 20:55:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: computing drop-able caches
Message-ID: <20160129015534.GA6401@cmpxchg.org>
References: <56AAA77D.7090000@cisco.com>
 <20160128235815.GA5953@cmpxchg.org>
 <56AABA79.3030103@cisco.com>
 <56AAC085.9060509@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56AAC085.9060509@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <danielwa@cisco.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>, Rik van Riel <riel@redhat.com>

On Thu, Jan 28, 2016 at 05:29:41PM -0800, Daniel Walker wrote:
> On 01/28/2016 05:03 PM, Daniel Walker wrote:
> [regarding MemAvaiable]
> 
> This new metric purportedly helps usrespace assess available memory. But,
> its again based on heuristic, it takes 1/2 of page cache as reclaimable..

No, it takes the smaller value of cache/2 and the low watermark, which
is a fraction of memory. Actually, that does look a little weird. Rik?

We don't age cache without memory pressure, you don't know how much is
used until you start taking some away. Heuristics is all we can offer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
