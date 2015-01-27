Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4A22A6B006E
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 03:36:43 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id l15so3298079wiw.0
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 00:36:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si1681985wiz.36.2015.01.27.00.36.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 00:36:41 -0800 (PST)
Message-ID: <54C74E17.6020703@suse.cz>
Date: Tue, 27 Jan 2015 09:36:39 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm/page_alloc: expands broken freepage to proper
 buddy list when steal
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com> <1418022980-4584-3-git-send-email-iamjoonsoo.kim@lge.com> <54856F88.8090300@suse.cz> <20141210063840.GC13371@js1304-P5Q-DELUXE> <54C73FB5.30000@suse.cz> <20150127083419.GF11358@js1304-P5Q-DELUXE>
In-Reply-To: <20150127083419.GF11358@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/27/2015 09:34 AM, Joonsoo Kim wrote:
> On Tue, Jan 27, 2015 at 08:35:17AM +0100, Vlastimil Babka wrote:
>> On 12/10/2014 07:38 AM, Joonsoo Kim wrote:
>> > After your patch is merged, I will resubmit these on top of it.
>> 
>> Hi Joonsoo,
>> 
>> my page stealing patches are now in -mm so are you planning to resubmit this? At
>> least patch 1 is an obvious bugfix, and patch 4 a clear compaction overhead
>> reduction. Those don't need to wait for the rest of the series. If you are busy
>> with other stuff, I can also resend those two myself if you want.
> 
> Hello,
> 
> I've noticed that your patches are merged. :)
> If you are in hurry, you can resend them. I'm glad if you handle it.
> If not, I will resend them, maybe, on end of this week.

Hi,

end of week is fine! I'm in no hurry, just wanted to know the status.

> In fact, I'm testing your stealing patches on my add-hoc fragmentation
> benchmark. It would be finished soon and, after that, I can resend this
> patchset.

Good to hear! Thanks.

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
