Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 618FD4405B1
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:30:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d185so191892314pgc.2
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 12:30:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e92si4728196pld.281.2017.02.15.12.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 12:30:56 -0800 (PST)
Date: Wed, 15 Feb 2017 12:30:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] Reduce amount of time kswapd sleeps prematurely
Message-Id: <20170215123055.b8041d7b6bdbcca9c5fd8dd9@linux-foundation.org>
In-Reply-To: <20170215092247.15989-1-mgorman@techsingularity.net>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, 15 Feb 2017 09:22:44 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> This patchset is based on mmots as of Feb 9th, 2016. The baseline is
> important as there are a number of kswapd-related fixes in that tree and
> a comparison against v4.10-rc7 would be almost meaningless as a result.

It's very late to squeeze this into 4.10.  We can make it 4.11 material
and perhaps tag it for backporting into 4.10.1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
