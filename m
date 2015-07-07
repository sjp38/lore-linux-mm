Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD666B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 10:21:58 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so126702035pdb.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:21:58 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id xy2si34987273pab.59.2015.07.07.07.21.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 07:21:57 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so126720475pdb.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:21:56 -0700 (PDT)
Date: Tue, 7 Jul 2015 23:21:09 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v6 6/7] zsmalloc: account the number of compacted pages
Message-ID: <20150707142109.GA1450@swordfish>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-7-git-send-email-sergey.senozhatsky@gmail.com>
 <20150707133916.GC3898@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150707133916.GC3898@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/07/15 22:39), Minchan Kim wrote:
[..]
> >  struct zs_pool_stats {
> > -	/* How many objects were migrated */
> > -	u64		num_migrated;
> > +	/* How many pages were migrated (freed) */
> > +	u64		pages_compacted;
> 
> Hmm, if we account it as page unit, unsigned long is enough for 32bit.

Well, this is a 'how many pages were freed overall' counter. We don't
control the lifetime of device, so I think it can be bigger than 4 bytes
in some `extreme' cases.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
