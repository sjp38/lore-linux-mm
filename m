Received: by rv-out-0910.google.com with SMTP id f1so1786558rvb.26
        for <linux-mm@kvack.org>; Wed, 27 Feb 2008 00:11:54 -0800 (PST)
Message-ID: <84144f020802270005p3bfbd04ar9da2875218ef98c4@mail.gmail.com>
Date: Wed, 27 Feb 2008 10:05:04 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
In-Reply-To: <1204099113.6242.353.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
	 <1204099113.6242.353.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Wed, Feb 27, 2008 at 9:58 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>  > 1/ I note there is no way to tell if memory returned by kmalloc is
>  >   from the emergency reserve - which contrasts with alloc_page
>  >   which does make that information available through page->reserve.
>  >   This seems a slightly unfortunate aspect of the interface.
>
>  Yes, but alas there is no room to store such information in kmalloc().
>  That is, in a sane way. I think it was Daniel Phillips who suggested
>  encoding it in the return pointer by flipping the low bit - but that is
>  just too ugly and breaks all current kmalloc sites to boot.

Why can't you add a kmem_is_emergency() to SLUB that looks up the
cache/slab/page (whatever is the smallest unit of the emergency pool
here) for the object and use that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
