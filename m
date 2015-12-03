Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id DF5AA6B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 04:38:53 -0500 (EST)
Received: by wmec201 with SMTP id c201so17721701wme.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 01:38:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ot8si10190361wjc.163.2015.12.03.01.38.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 01:38:52 -0800 (PST)
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
 <20151203092525.GA20945@aaronlu.sh.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56600DAA.4050208@suse.cz>
Date: Thu, 3 Dec 2015 10:38:50 +0100
MIME-Version: 1.0
In-Reply-To: <20151203092525.GA20945@aaronlu.sh.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

On 12/03/2015 10:25 AM, Aaron Lu wrote:
> On Thu, Dec 03, 2015 at 09:10:44AM +0100, Vlastimil Babka wrote:
>> Aaron, could you try this on your testcase?
> 
> The test result is placed at:
> https://drive.google.com/file/d/0B49uX3igf4K4enBkdVFScXhFM0U
> 
> For some reason, the patches made the performace worse. The base tree is
> today's Linus git 25364a9e54fb8296837061bf684b76d20eec01fb, and its
> performace is about 1000MB/s. After applying this patch series, the
> performace drops to 720MB/s.
> 
> Please let me know if you need more information, thanks.

Hm, compaction stats are at 0. The code in the patches isn't even running.
Can you provide the same data also for the base tree?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
