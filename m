Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0956B0032
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 03:58:11 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so27140960wgh.1
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 00:58:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hl4si112032516wjb.1.2015.01.05.00.58.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 00:58:10 -0800 (PST)
Message-ID: <54AA5220.5080205@suse.cz>
Date: Mon, 05 Jan 2015 09:58:08 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/compaction: enhance trace output to know more
 about compaction internals
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com> <20150105023352.GB3534@js1304-P5Q-DELUXE>
In-Reply-To: <20150105023352.GB3534@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/05/2015 03:33 AM, Joonsoo Kim wrote:
> On Wed, Dec 03, 2014 at 04:52:05PM +0900, Joonsoo Kim wrote:
>> It'd be useful to know where the both scanner is start. And, it also be
>> useful to know current range where compaction work. It will help to find
>> odd behaviour or problem on compaction.
>> 
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hello, Andrew and Vlastimil.
> 
> Could you review or merge this patchset?

I hope to review it soon, just "recovering" from a vacation ;-)

> It would help to trace compaction behaviour.

Yep,
Thanks

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
