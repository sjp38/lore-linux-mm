From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][PATCH] Avoid vmtruncate/mmap-page-fault race
Date: Thu, 29 May 2003 19:39:47 +0200
References: <Pine.LNX.4.44.0305291723310.1800-100000@localhost.localdomain> <200305291915.22235.phillips@arcor.de>
In-Reply-To: <200305291915.22235.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200305291939.47451.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: akpm@digeo.com, hch@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 29 May 2003 19:15, Daniel Phillips wrote:
> On Thursday 29 May 2003 18:33, you wrote:
> > Me?  I much preferred your original, much sparer, nopagedone patch
> > (labelled "uglyh as hell" by hch).
>
> "me too".

Oh wait, I mispoke... there is another formulation of the patch that hasn't 
yet been posted for review.  Instead of having the nopagedone hook, it turns 
the entire do_no_page into a hook, per hch's suggestion, but leaves in the 
->nopage hook, which makes the patch small and obviously right.  I need to 
post that version for comparison, please bear with me.

IMHO, it's nicer than the ->nopagedone form.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
