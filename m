Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C41916B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:10:34 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y82so134549140oig.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 12:10:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i14si32023214ioe.65.2016.06.14.12.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 12:10:34 -0700 (PDT)
Subject: Re: [PATCH v2 1/7] mm/compaction: split freepages without holding the
 zone lock
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <575F1813.4020700@oracle.com> <20160614055257.GA13753@js1304-P5Q-DELUXE>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5760569D.6030907@oracle.com>
Date: Tue, 14 Jun 2016 15:10:21 -0400
MIME-Version: 1.0
In-Reply-To: <20160614055257.GA13753@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/14/2016 01:52 AM, Joonsoo Kim wrote:
> On Mon, Jun 13, 2016 at 04:31:15PM -0400, Sasha Levin wrote:
>> > On 05/25/2016 10:37 PM, js1304@gmail.com wrote:
>>> > > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>> > > 
>>> > > We don't need to split freepages with holding the zone lock. It will cause
>>> > > more contention on zone lock so not desirable.
>>> > > 
>>> > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> > 
>> > Hey Joonsoo,
> Hello, Sasha.
>> > 
>> > I'm seeing the following corruption/crash which seems to be related to
>> > this patch:
> Could you tell me why you think that following corruption is related
> to this patch? list_del() in __isolate_free_page() is unchanged part.
> 
> Before this patch, we did it by split_free_page() ->
> __isolate_free_page() -> list_del(). With this patch, we do it by
> calling __isolate_free_page() directly.

I haven't bisected it, but it's the first time I see this issue and this
commit seems to have done related changes that might cause this.

I can go ahead with bisection if you don't think it's related.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
