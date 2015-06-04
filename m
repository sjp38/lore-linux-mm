Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE65900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 00:18:49 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so20824532pab.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 21:18:48 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id gu1si3894865pbd.210.2015.06.03.21.18.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 21:18:48 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so21876988pdb.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 21:18:47 -0700 (PDT)
Date: Thu, 4 Jun 2015 13:19:11 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 03/10] zsmalloc: introduce zs_can_compact() function
Message-ID: <20150604041911.GI1951@swordfish>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604025533.GE2241@blaptop>
 <20150604031514.GE1951@swordfish>
 <20150604033014.GG2241@blaptop>
 <20150604034230.GH1951@swordfish>
 <20150604035025.GH2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604035025.GH2241@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (06/04/15 12:50), Minchan Kim wrote:
> > On (06/04/15 12:30), Minchan Kim wrote:
> > > 
> > > What scenario do you have a cocern?
> > > Could you describe this example more clear?
> > 
> > you mean "how is this even possible"?
> 
> No I meant. I couldn't understand your terms. Sorry.
> 
> What free-objs class capacity is?
> page1 is zspage?
> 
> Let's use consistent terms between us.
> 
> For example, maxobj-per-zspage is 4.
> A is allocated and used. X is allocated but not used.
> so we can draw a zspage below.
> 
>         AAXX
> 
> So we can draw several zspages linked list as below
> 
> AAXX - AXXX - AAAX
> 
> Could you describe your problem again?
> 
> Sorry.

My apologies.

yes, so:
-- free-objs class capacity -- how may unused allocated objects
we have in this class (in total).
-- page1..pageN -- zspages.

And I think that my example is utterly wrong and incorrect. My mistake.
Sorry for the noise.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
