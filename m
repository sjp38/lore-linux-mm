Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6392E6B004F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 08:36:16 -0400 (EDT)
Subject: Re: [PATCH] Add a gfp-translate script to help understand page
 allocation failure reports
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <4A2D15DD.1030005@redhat.com>
References: <20090608132950.GB15070@csn.ul.ie> <4A2D15DD.1030005@redhat.com>
Date: Mon, 08 Jun 2009 16:53:33 +0300
Message-Id: <1244469213.6315.6.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-08 at 09:45 -0400, Rik van Riel wrote:
> Mel Gorman wrote:
> 
> >   mel@machina:~/linux-2.6 $ scripts/gfp-translate 0x4020
> >   Source: /home/mel/linux-2.6
> >   Parsing: 0x4020
> >   #define __GFP_HIGH	(0x20)	/* Should access emergency pools? */
> >   #define __GFP_COMP	(0x4000) /* Add compound page metadata */
> > 
> > The script is not a work of art but it has come in handy for me a few times
> > so I thought I would share.
> 
> Sweet.  This is just what I've been waiting for!
> 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> Acked-by: Rik van Riel <riel@redhat.com>

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
