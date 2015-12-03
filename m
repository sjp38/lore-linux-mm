Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id A15836B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 04:25:29 -0500 (EST)
Received: by pfbg73 with SMTP id g73so6677355pfb.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 01:25:29 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id zz9si10871347pac.245.2015.12.03.01.25.28
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 01:25:28 -0800 (PST)
Date: Thu, 3 Dec 2015 17:25:25 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
Message-ID: <20151203092525.GA20945@aaronlu.sh.intel.com>
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

On Thu, Dec 03, 2015 at 09:10:44AM +0100, Vlastimil Babka wrote:
> Aaron, could you try this on your testcase?

The test result is placed at:
https://drive.google.com/file/d/0B49uX3igf4K4enBkdVFScXhFM0U

For some reason, the patches made the performace worse. The base tree is
today's Linus git 25364a9e54fb8296837061bf684b76d20eec01fb, and its
performace is about 1000MB/s. After applying this patch series, the
performace drops to 720MB/s.

Please let me know if you need more information, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
