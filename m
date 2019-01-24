Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BED428E007C
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 03:53:28 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so2031984edc.6
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 00:53:28 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id e17si2143830ejm.95.2019.01.24.00.53.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 00:53:27 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 0B032B8B25
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 08:53:27 +0000 (GMT)
Date: Thu, 24 Jan 2019 08:53:25 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/22] Increase success rates and reduce latency of
 compaction v3
Message-ID: <20190124085325.GT27437@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Jan 18, 2019 at 05:51:14PM +0000, Mel Gorman wrote:
> This is a drop-in replacement for the series currently in Andrews tree that
> incorporates static checking and compile warning fixes (Dan, YueHaibing)
> and extensive review feedback from Vlastimil. Big thanks to Vlastimil as
> the review was extremely detailed and a number of issues were caught. Not
> all the patches have been acked but I think an update is still worthwhile.
> 
> Andrew, please drop the series you have and replace it with the following
> on the off-chance we get bug reports that are fixed already. Doing this
> with -fix patches would be relatively painful for little gain.
> 

Andrew?

-- 
Mel Gorman
SUSE Labs
