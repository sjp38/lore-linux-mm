Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7D26F6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 20:48:10 -0400 (EDT)
Received: by iesa3 with SMTP id a3so44549082ies.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 17:48:10 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0172.hostedemail.com. [216.40.44.172])
        by mx.google.com with ESMTP id zp5si10255556icb.30.2015.06.10.17.48.09
        for <linux-mm@kvack.org>;
        Wed, 10 Jun 2015 17:48:09 -0700 (PDT)
Message-ID: <1433983686.32331.35.camel@perches.com>
Subject: Re: [RFC][PATCH 4/5] mm/zpool: allow NULL `zpool' pointer in
 zpool_destroy_pool()
From: Joe Perches <joe@perches.com>
Date: Wed, 10 Jun 2015 17:48:06 -0700
In-Reply-To: <20150610235836.GB499@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
	 <1433851493-23685-5-git-send-email-sergey.senozhatsky@gmail.com>
	 <CALZtONAyQn1qGusF4TXcS1FHmiHNmJT+Wrh2G6j7OYA=R+Q0dQ@mail.gmail.com>
	 <20150610235836.GB499@swordfish>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, 2015-06-11 at 08:58 +0900, Sergey Senozhatsky wrote:
> On (06/10/15 16:59), Dan Streetman wrote:
> > On Tue, Jun 9, 2015 at 8:04 AM, Sergey Senozhatsky
> > <sergey.senozhatsky@gmail.com> wrote:
> > > zpool_destroy_pool() does not tolerate a NULL zpool pointer
> > > argument and performs a NULL-pointer dereference. Although
> > > there is only one zpool_destroy_pool() user (as of 4.1),
> > > still update it to be coherent with the corresponding
> > > destroy() functions of the remainig pool-allocators (slab,
> > > mempool, etc.), which now allow NULL pool-pointers.
> > >
> > > For consistency, tweak zpool_destroy_pool() and NULL-check the
> > > pointer there.
> > >
> > > Proposed by Andrew Morton.
> > >
> > > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > Reported-by: Andrew Morton <akpm@linux-foundation.org>
> > > LKML-reference: https://lkml.org/lkml/2015/6/8/583
> > 
> > Acked-by: Dan Streetman <ddstreet@ieee.org>
> 
> Thanks.
> 
> Shall we ask Joe to add zpool_destroy_pool() to the
> "$func(NULL) is safe and this check is probably not required" list?

[]

Is it really worth it?

There isn't any use of zpool_destroy_pool preceded by an if
There is one and only one use of zpool_destroy_pool.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
