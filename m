Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3CF506B01FA
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 13:46:21 -0400 (EDT)
Date: Wed, 21 Apr 2010 19:46:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch] ksm: check for ERR_PTR from follow_page()
Message-ID: <20100421174615.GO32034@random.random>
References: <20100421102759.GA29647@bicker>
 <4BCF18A8.8080809@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BCF18A8.8080809@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Dan Carpenter <error27@gmail.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 21, 2010 at 11:24:24AM -0400, Rik van Riel wrote:
> On 04/21/2010 06:27 AM, Dan Carpenter wrote:
> > The follow_page() function can potentially return -EFAULT so I added
> > checks for this.
> >
> > Also I silenced an uninitialized variable warning on my version of gcc
> > (version 4.3.2).
> >
> > Signed-off-by: Dan Carpenter<error27@gmail.com>
> 
> Acked-by: Rik van Riel <riel@redhat.com>

  	    	while (!(page = follow_page(vma, start, foll_flags)))
  	    	{

gup only checks for null, so when exactly is follow_page going to
return -EFAULT? It's not immediately clear.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
