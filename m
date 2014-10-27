Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id E2CF86B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 05:11:38 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so5523499lab.34
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 02:11:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si18909931lat.82.2014.10.27.02.11.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 02:11:36 -0700 (PDT)
Message-ID: <544E0C43.3030009@suse.cz>
Date: Mon, 27 Oct 2014 10:11:31 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm, compaction: pass classzone_idx and alloc_flags
 to watermark checking
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz> <1412696019-21761-2-git-send-email-vbabka@suse.cz> <20141027064651.GA23379@js1304-P5Q-DELUXE>
In-Reply-To: <20141027064651.GA23379@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 10/27/2014 07:46 AM, Joonsoo Kim wrote:
> On Tue, Oct 07, 2014 at 05:33:35PM +0200, Vlastimil Babka wrote:
> 
> Hello,
> 
> compaction_suitable() has one more zone_watermark_ok(). Why is it
> unchanged?

Hi,

it's a check whether there are enough free pages to perform compaction,
which means enough migration targets and temporary copies during
migration. These allocations are not affected by the flags of the
process that makes the high-order allocation.

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
