Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 99664900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 21:06:12 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id x13so3247794wgg.20
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 18:06:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id gt1si8070wjc.54.2014.10.27.18.06.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Oct 2014 18:06:10 -0700 (PDT)
Date: Tue, 28 Oct 2014 03:02:24 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 05/10] uprobes: share the i_mmap_rwsem
Message-ID: <20141028020224.GA28581@redhat.com>
References: <1414188380-17376-1-git-send-email-dave@stgolabs.net> <1414188380-17376-6-git-send-email-dave@stgolabs.net> <20141027070329.GA10867@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141027070329.GA10867@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org

On 10/27, Srikar Dronamraju wrote:
>
> Copying Oleg (since he should have been copied on this one)

Thanks ;)

> Please see one comment below.
>
> Acked-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com> 
>
> > ---
> >  kernel/events/uprobes.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> > index 045b649..7a9e620 100644
> > --- a/kernel/events/uprobes.c
> > +++ b/kernel/events/uprobes.c
> > @@ -724,7 +724,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
> >  	int more = 0;
> >  
> >   again:
> > -	i_mmap_lock_write(mapping);
> > +	i_mmap_lock_read(mapping);

I too think the patch is fine.

I didn't see other changes, but I hope that i_mmap_lock_write/read names
provide enough info and ->i_mmap_mutex was turned into rw-lock,  in this
case read-lock should be enough.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
