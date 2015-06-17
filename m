Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6718C6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 19:53:40 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so51990850pdj.3
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:53:40 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id ot7si8525511pac.203.2015.06.17.16.53.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 16:53:39 -0700 (PDT)
Received: by pabvl15 with SMTP id vl15so1283523pab.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:53:39 -0700 (PDT)
Date: Thu, 18 Jun 2015 08:54:06 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 2/5] mm/mempool: allow NULL `pool' pointer in
 mempool_destroy()
Message-ID: <20150617235406.GB3422@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433851493-23685-3-git-send-email-sergey.senozhatsky@gmail.com>
 <alpine.DEB.2.10.1506171619370.8203@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506171619370.8203@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On (06/17/15 16:21), David Rientjes wrote:
[..]
> > Tweak mempool_destroy() and NULL-check the pointer there.
> > 
> > Proposed by Andrew Morton.
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Reported-by: Andrew Morton <akpm@linux-foundation.org>
> > LKML-reference: https://lkml.org/lkml/2015/6/8/583
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> I like how your patch series is enabling us to remove many lines from the 
> source code.  But doing s/Reported-by/Suggested-by/ can also make your 
> changelog two lines shorter ;)
> 

Thanks.

Oh, s/Reported-by/Suggested-by/ looks better, indeed.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
