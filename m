Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 762C96B0256
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 18:58:38 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l66so33122563wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 15:58:38 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 190si7254187wmh.45.2016.01.28.15.58.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 15:58:37 -0800 (PST)
Date: Thu, 28 Jan 2016 18:58:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: computing drop-able caches
Message-ID: <20160128235815.GA5953@cmpxchg.org>
References: <56AAA77D.7090000@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56AAA77D.7090000@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <danielwa@cisco.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

On Thu, Jan 28, 2016 at 03:42:53PM -0800, Daniel Walker wrote:
> "Currently there is no way to figure out the droppable pagecache size
> from the meminfo output. The MemFree size can shrink during normal
> system operation, when some of the memory pages get cached and is
> reflected in "Cached" field. Similarly for file operations some of
> the buffer memory gets cached and it is reflected in "Buffers" field.
> The kernel automatically reclaims all this cached & buffered memory,
> when it is needed elsewhere on the system. The only way to manually
> reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. "

[...]

> The point of the whole exercise is to get a better idea of free memory for
> our employer. Does it make sense to do this for computing free memory?

/proc/meminfo::MemAvailable was added for this purpose. See the doc
text in Documentation/filesystem/proc.txt.

It's an approximation, however, because this question is not easy to
answer. Pages might be in various states and uses that can make them
unreclaimable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
