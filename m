Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id EEEC16B0087
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 04:26:50 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so19201474pdj.26
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 01:26:50 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id kk11si52098040pbd.119.2014.08.25.01.26.49
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 01:26:50 -0700 (PDT)
Date: Mon, 25 Aug 2014 17:26:54 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] mm/slab_common: commonize slab merge logic
Message-ID: <20140825082654.GB13475@js1304-P5Q-DELUXE>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1408608675-20420-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.11.1408210922020.32524@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408210922020.32524@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 21, 2014 at 09:22:35AM -0500, Christoph Lameter wrote:
> On Thu, 21 Aug 2014, Joonsoo Kim wrote:
> 
> > Slab merge is good feature to reduce fragmentation. Now, it is only
> > applied to SLUB, but, it would be good to apply it to SLAB. This patch
> > is preparation step to apply slab merge to SLAB by commonizing slab
> > merge logic.
> 
> Oh. Wow. Never thought that would be possible. Need to have some more time
> to review this though.

Yes, please review it. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
