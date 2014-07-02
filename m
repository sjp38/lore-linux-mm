Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4325B6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 20:41:07 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id ty20so6523221lab.11
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 17:41:06 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id zw4si42183394lbb.35.2014.07.01.17.41.04
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 17:41:06 -0700 (PDT)
Date: Wed, 2 Jul 2014 09:46:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 4/9] slab: factor out initialization of arracy cache
Message-ID: <20140702004615.GC9972@js1304-P5Q-DELUXE>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1404203258-8923-5-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1407011525350.4004@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407011525350.4004@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

On Tue, Jul 01, 2014 at 03:26:26PM -0700, David Rientjes wrote:
> On Tue, 1 Jul 2014, Joonsoo Kim wrote:
> 
> > Factor out initialization of array cache to use it in following patch.
> > 
> > Acked-by: Christoph Lameter <cl@linux.com>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Not sure what happened to my
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> from http://marc.info/?l=linux-mm&m=139951195724487 and my comment still 
> stands about s/arracy/array/ in the patch title.

This is new one with applying your comment.

Thanks.

--------------8<--------------
