Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD7076B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 18:27:40 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u65so5009892wrc.8
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 15:27:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q109si3650855wrb.181.2018.03.01.15.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 15:27:39 -0800 (PST)
Date: Thu, 1 Mar 2018 15:27:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, compaction: drain pcps for zone when kcompactd
 fails
Message-Id: <20180301152737.62b78dcb129339a3261a9820@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.20.1803010340100.88270@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803010340100.88270@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 1 Mar 2018 03:42:04 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> It's possible for buddy pages to become stranded on pcps that, if drained,
> could be merged with other buddy pages on the zone's free area to form
> large order pages, including up to MAX_ORDER.

I grabbed this as-is.  Perhaps you could send along a new changelog so
that others won't be asking the same questions as Vlastimil?

The patch has no reviews or acks at this time...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
