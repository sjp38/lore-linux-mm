Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E95166B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 20:59:32 -0400 (EDT)
Received: by payr10 with SMTP id r10so43921248pay.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 17:59:32 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id hu6si16474692pac.153.2015.06.10.17.59.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 17:59:32 -0700 (PDT)
Received: by pablj1 with SMTP id lj1so12635541pab.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 17:59:31 -0700 (PDT)
Date: Thu, 11 Jun 2015 09:59:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 4/5] mm/zpool: allow NULL `zpool' pointer in
 zpool_destroy_pool()
Message-ID: <20150611005956.GA515@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433851493-23685-5-git-send-email-sergey.senozhatsky@gmail.com>
 <CALZtONAyQn1qGusF4TXcS1FHmiHNmJT+Wrh2G6j7OYA=R+Q0dQ@mail.gmail.com>
 <20150610235836.GB499@swordfish>
 <1433983686.32331.35.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433983686.32331.35.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On (06/10/15 17:48), Joe Perches wrote:
[..]
> > > > For consistency, tweak zpool_destroy_pool() and NULL-check the
> > > > pointer there.
> > > >
> > > > Proposed by Andrew Morton.
> > > >
> > > > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > > Reported-by: Andrew Morton <akpm@linux-foundation.org>
> > > > LKML-reference: https://lkml.org/lkml/2015/6/8/583
> > > 
> > > Acked-by: Dan Streetman <ddstreet@ieee.org>
> > 
> > Thanks.
> > 
> > Shall we ask Joe to add zpool_destroy_pool() to the
> > "$func(NULL) is safe and this check is probably not required" list?
> 
> []
> 
> Is it really worth it?
> 
> There isn't any use of zpool_destroy_pool preceded by an if
> There is one and only one use of zpool_destroy_pool.
> 

Yes, that's why I asked. I don't think that zpool_destroy_pool()
will gain any significant amount of users soon (well, who knows),
so I'm fine with keeping it out of checkpatch checks. Just checked
your opinion.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
