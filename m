Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9BF1F6B00CC
	for <linux-mm@kvack.org>; Wed, 13 May 2009 04:37:38 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so305091rvb.26
        for <linux-mm@kvack.org>; Wed, 13 May 2009 01:38:12 -0700 (PDT)
Date: Wed, 13 May 2009 17:37:58 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: kernel BUG at mm/slqb.c:1411!
Message-Id: <20090513173758.2f3d2a50.minchan.kim@barrios-desktop>
In-Reply-To: <20090513163826.7232.A69D9226@jp.fujitsu.com>
References: <20090513163826.7232.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009 16:42:37 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

Hmm. I don't know slqb well.
So, It's just my guess. 

We surely increase l->nr_partial in  __slab_alloc_page.
In between l->nr_partial++ and call __cache_list_get_page, Who is decrease l->nr_partial again.
After all, __cache_list_get_page return NULL and hit the VM_BUG_ON.

Comment said :

        /* Protects nr_partial, nr_slabs, and partial */
  spinlock_t    page_lock;

As comment is right, We have to hold the l->page_lock ?



-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
