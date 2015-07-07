Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BDFA26B0253
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 10:33:58 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so114273668pac.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:33:58 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id co3si34969871pad.233.2015.07.07.07.33.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 07:33:57 -0700 (PDT)
Received: by pdbdz6 with SMTP id dz6so32147913pdb.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:33:56 -0700 (PDT)
Date: Tue, 7 Jul 2015 23:33:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 6/7] zsmalloc: account the number of compacted pages
Message-ID: <20150707143347.GA23003@blaptop>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-7-git-send-email-sergey.senozhatsky@gmail.com>
 <20150707133916.GC3898@blaptop>
 <20150707142109.GA1450@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150707142109.GA1450@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Tue, Jul 07, 2015 at 11:21:09PM +0900, Sergey Senozhatsky wrote:
> On (07/07/15 22:39), Minchan Kim wrote:
> [..]
> > >  struct zs_pool_stats {
> > > -	/* How many objects were migrated */
> > > -	u64		num_migrated;
> > > +	/* How many pages were migrated (freed) */
> > > +	u64		pages_compacted;
> > 
> > Hmm, if we account it as page unit, unsigned long is enough for 32bit.
> 
> Well, this is a 'how many pages were freed overall' counter. We don't
> control the lifetime of device, so I think it can be bigger than 4 bytes
> in some `extreme' cases.

Technically, you're right but we have been used "unsigned long" for
seval mm stats for a long time. For exmaple, vm_event_item.
It includes many stats accumulated for the system running time.
I don't think zsmalloc is special.

> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
