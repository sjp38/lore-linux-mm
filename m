Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E794C6B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 06:35:12 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so69860566pab.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 03:35:12 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id a73si11633986pfj.40.2015.12.03.03.35.10
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 03:35:10 -0800 (PST)
Date: Thu, 3 Dec 2015 19:35:08 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
Message-ID: <20151203113508.GA23780@aaronlu.sh.intel.com>
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
 <20151203092525.GA20945@aaronlu.sh.intel.com>
 <56600DAA.4050208@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56600DAA.4050208@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

On Thu, Dec 03, 2015 at 10:38:50AM +0100, Vlastimil Babka wrote:
> On 12/03/2015 10:25 AM, Aaron Lu wrote:
> > On Thu, Dec 03, 2015 at 09:10:44AM +0100, Vlastimil Babka wrote:
> >> Aaron, could you try this on your testcase?
> > 
> > The test result is placed at:
> > https://drive.google.com/file/d/0B49uX3igf4K4enBkdVFScXhFM0U
> > 
> > For some reason, the patches made the performace worse. The base tree is
> > today's Linus git 25364a9e54fb8296837061bf684b76d20eec01fb, and its
> > performace is about 1000MB/s. After applying this patch series, the
> > performace drops to 720MB/s.
> > 
> > Please let me know if you need more information, thanks.
> 
> Hm, compaction stats are at 0. The code in the patches isn't even running.
> Can you provide the same data also for the base tree?

My bad, I uploaded the wrong data :-/
I uploaded again:
https://drive.google.com/file/d/0B49uX3igf4K4UFI4TEQ3THYta0E

And I just run the base tree with trace-cmd and found that its
performace drops significantly(from 1000MB/s to 6xxMB/s), is it that
trace-cmd will impact performace a lot? Any suggestions on how to run
the test regarding trace-cmd? i.e. should I aways run usemem under
trace-cmd or only when necessary?

Thanks,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
